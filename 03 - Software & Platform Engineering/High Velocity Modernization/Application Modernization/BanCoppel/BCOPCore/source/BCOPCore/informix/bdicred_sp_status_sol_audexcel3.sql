CREATE PROCEDURE "informix".sp_status_sol_audexcel3(pUsuario CHAR(8), pempresa CHAR(3),psucursal CHAR(4),pfechaini CHAR(10),pfechafin CHAR(10),pstatus CHAR(2),
pRegion CHAR(3),pNumCte CHAR(20))
RETURNING CHAR(5);
		  
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
--
DEFINE bInTransaccion   BOOLEAN;
DEFINE iRow INTEGER;
DEFINE iContBloque INTEGER;
DEFINE iRecuperacion INTEGER;

-- sc
DEFINE cEmpleadoAsigna CHAR(45);
DEFINE cEmpleadoActiva CHAR(45);
DEFINE cEjecutivoAutoriza CHAR(45);

-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET cCod_ret     = "00000";
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
--
LET bInTransaccion   = 'f';
LET iRow = 0;
LET iContBloque = 0;
LET iRecuperacion = 0;

LET cEmpleadoAsigna = "";
LET cEmpleadoActiva = "";
LET cEjecutivoAutoriza = "";

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
	ON EXCEPTION SET iSqlerr,iIsamErr,cMen_ret
	   Let cCod_ret = iSqlerr;
	   
	   DROP TABLE IF EXISTS sw_cnt_detallesol_temp;
	   
	   RETURN cCod_ret;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		COMMIT WORK;
		BEGIN WORK;
		LET bInTransaccion = 't';                       
	END EXCEPTION WITH RESUME;

 --SET DEBUG FILE TO "/informix/jesus/sp_status_sol_audexcel.out";
 --TRACE ON;
	--SET DEBUG FILE TO "/tmp/mfinis/sp_status_sol_audexcel3.out";
	--TRACE ON;
-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************

    IF NVL(pSucursal, '') = '' THEN
		LET pSucursal = '';
        --LET  cCod_ret = '00001';
		--LET cMen_ret = 'LA SUCURSAL ES UN DATO REQUERIDO PARA LA EXPORTACION A EXCEL';
		--RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		--NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
	END IF;
    IF NVL(pStatus, '') = '' THEN
		LET pStatus = '';
        --LET  cCod_ret = '00002';
		--LET cMen_ret = 'EL ESTATUS ES UN DATO REQUERIDO PARA LA EXPORTACION A EXCEL';		
		--RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		--NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
    END IF;
	IF NVL(pRegion, '') = '' THEN
		LET pRegion = '';
	END IF;
	IF NVL(pNumCte, '') = '' THEN
		LET pNumCte = '';
	END IF;
	
	--SELECT  COUNT(valor_alfabetico)
	--INTO iConStatus
	--FROM "informix".sd_param_campania
	--WHERE empresa = pempresa
	--AND tipo_campania = 65
	--AND grupo_parametro ='EXCELAUDI'
	--AND TRIM(valor_alfabetico) = pStatus;
    --
	--IF iConStatus = 0 THEN
	--	LET  cCod_ret = '00003';
	--	LET cMen_ret = 'EL ESTATUS NO ES VALIDO PARA LA EXPORTACION A EXCEL';		
	--	RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
	--	NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
	--END IF;
	--validacion de los dias de consulta
	
	SELECT  valor
	INTO iDiasConsultaExcel
	FROM "informix".sd_param
	WHERE empresa = pempresa
	AND cod_param = '084';
	
	 LET  iDiasConsulta = pFechafin::DATE - pFechaini::DATE ;
	 
	 IF iDiasConsulta > iDiasConsultaExcel THEN
	 	LET  cCod_ret = '00004';
		RETURN cCod_ret;
	 END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- SE LLENA TABLA TEMPORAL
	SELECT a.num_solicitud, a.numcte, a.status_solicitud,nvl(a.monto_solicitado,0) AS monto_solicitado,
	nvl(a.monto_autorizado,0) AS monto_autorizado,nvl(a.fecha_insert,date(1)) AS fecha_insert, a.sucursal,a.user_insert
	--INTO cNumSol,cNumcte,cStatus,mMonto,mMonto_aut,dtFechaSol ,cSucursal,cUsuarioAlta
	FROM bdisolic:"informix".ss_solicitudes  a
	INNER JOIN bdisolic:"informix".ss_anexosol b ON (b.empresa = a.empresa AND b.num_solicitud = a.num_solicitud) 
	WHERE a.empresa = pEmpresa 
	-- SC AND a.num_solicitud >=''		
	-- SC AND a.fecha_insert BETWEEN pFechaini::DATE AND  pFechafin::DATE
	AND a.fecha_insert >= pFechaini::DATE AND a.fecha_insert <= pFechafin::DATE
	--AND a.status_solicitud = pStatus
	AND a.status_solicitud = (CASE WHEN pStatus = '' THEN a.status_solicitud ELSE pStatus END)
	--AND a.sucursal = pSucursal
	AND a.sucursal = (CASE WHEN pSucursal = '' THEN a.sucursal ELSE pSucursal END)
	AND a.numcte = (CASE WHEN pNumCte = '' THEN a.numcte ELSE pNumCte END)
	AND (NVL(a.regional,'') = (CASE WHEN pRegion = '' THEN NVL(a.regional,'') ELSE pRegion END) OR NVL(a.regional,'') = '')							
	--AND NVL(a.regional,'') = NVL(a.regional,'')
	INTO TEMP sw_cnt_detallesol_temp WITH NO LOG;
	
	BEGIN WORK;
	FOREACH WITH HOLD
--OK SC

		--LET cEmpleadoAsigna = "";
		--LET cEmpleadoActiva = "";
		--LET cEjecutivoAutoriza = "";

		/*SELECT a.num_solicitud, a.numcte, a.status_solicitud,nvl(a.monto_solicitado,0),
		nvl(a.monto_autorizado,0),nvl(a.fecha_insert,date(1)), a.sucursal,a.user_insert
		INTO cNumSol,cNumcte,cStatus,mMonto,mMonto_aut,dtFechaSol ,cSucursal,cUsuarioAlta
		FROM bdisolic:"informix".ss_solicitudes  a
		INNER JOIN bdisolic:"informix".ss_anexosol b ON (b.empresa = a.empresa AND b.num_solicitud = a.num_solicitud) 
		WHERE a.empresa = pEmpresa 
		-- SC AND a.num_solicitud >=''		
		-- SC AND a.fecha_insert BETWEEN pFechaini::DATE AND  pFechafin::DATE
		AND a.fecha_insert >= pFechaini::DATE AND a.fecha_insert <= pFechafin::DATE
		--AND a.status_solicitud = pStatus
		AND a.status_solicitud = (CASE WHEN pStatus = '' THEN a.status_solicitud ELSE pStatus END)
		--AND a.sucursal = pSucursal
		AND a.sucursal = (CASE WHEN pSucursal = '' THEN a.sucursal ELSE pSucursal END)
		AND a.numcte = (CASE WHEN pNumCte = '' THEN a.numcte ELSE pNumCte END)
		AND (NVL(a.regional,'') = (CASE WHEN pRegion = '' THEN NVL(a.regional,'') ELSE pRegion END) OR NVL(a.regional,'') = '')							
		--AND NVL(a.regional,'') = NVL(a.regional,'')*/
		
		-- SE CONSULTA TABLA TEMP
		SELECT num_solicitud,numcte,status_solicitud,monto_solicitado,monto_autorizado,fecha_insert,sucursal,user_insert
		INTO cNumSol,cNumcte,cStatus,mMonto,mMonto_aut,dtFechaSol,cSucursal,cUsuarioAlta
		FROM sw_cnt_detallesol_temp
		
		-- original 11062019
		--SELECT pf.estado_civil,TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno)
		--INTO cEstadocivil,cNomCte
		--FROM bdinteg:"informix".si_cliente cte
		--INNER JOIN bdinteg:"informix".si_ctepf pf ON (pf.Empresa = cte.empresa and pf.numcte= cte.numcte)
		--WHERE cte.empresa = pEmpresa 
		--AND cte.numcte = cNumcte;  
		
		--SC 11062019
        SELECT TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno)
		INTO cNomCte
		FROM bdinteg:"informix".si_cliente cte
		WHERE cte.empresa = pEmpresa 
		AND cte.numcte = cNumcte;  
		
		SELECT pf.estado_civil
		INTO cEstadocivil
		FROM bdinteg:"informix".si_ctepf pf 
		WHERE pf.Empresa = pEmpresa 
		AND pf.numcte = cNumcte; 
		
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
			
			-- ORIGINAL 11092019
			--SELECT LIMIT 1 NVL(eje.nombre,""),aut.fecha_insert--Usuario que aperturo el crÃ?Â©dito.
			--INTO cNombrePromAutoriza,dtFechaCam
			--FROM bdisolic:"informix".ss_autorizacion aut
			--INNER JOIN bdinteg:"informix".si_ejecut eje ON eje.empresa = pEmpresa AND eje.ejecutivo = aut.ejecutivo_auto
			--WHERE aut.empresa=pEmpresa 
			--AND aut.num_solicitud=cNumSol
			--AND aut.status_solicitud = "AP";
			
			-- SC
			SELECT LIMIT 1 aut.fecha_insert, aut.ejecutivo_auto--Usuario que aperturo el crÃ?Â©dito.
			INTO dtFechaCam, cEjecutivoAutoriza
			FROM bdisolic:"informix".ss_autorizacion aut
			WHERE aut.empresa=pEmpresa 
			AND aut.num_solicitud=cNumSol
			AND aut.status_solicitud = "AP";
			
			-- SC
			SELECT LIMIT 1 NVL(eje.nombre,"") --Usuario que aperturo el crÃ?Â©dito.
			INTO cNombrePromAutoriza
			FROM bdinteg:"informix".si_ejecut eje 
			WHERE eje.ejecutivo = cEjecutivoAutoriza
			AND eje.empresa = pEmpresa;
			
			IF SUBSTR(cNumSol,1,2)= "60" THEN
				SELECT monto_otorgado
				INTO mMonto_aut
				FROM bdicred:"informix".sd_maesdos
				WHERE empresa=pEmpresa and num_credito=cNumSol;
				
				-- ORIGINAL 11092019
				-- SELECT LIMIT 1 NVL(eje.nombre,""),NVL(eje2.nombre,"")--Usuario que aperturo el crÃ?Â©dito.
				-- INTO cNombrePromEntrega,cNombrePromActiva
				-- FROM "informix".sd_tarjeta tar
				-- INNER JOIN "informix".bitacora_activacion act ON (act.numtarjeta =tar.num_tarjeta)
				-- LEFT JOIN bdinteg:"informix".si_ejecut eje ON (eje.empresa = '001' AND eje.ejecutivo = act.no_empleado_asigna)
				-- LEFT JOIN bdinteg:"informix".si_ejecut eje2 ON (eje2.empresa = '001' AND eje2.ejecutivo = act.no_empleado_activa)
				-- WHERE tar.empresa=pEmpresa 
				-- AND tar.num_credito=cNumSol
				-- AND tar.secuencia ='1';
								
				-- sc 11092019
				SELECT act.no_empleado_asigna, act.no_empleado_activa
				INTO cEmpleadoAsigna, cEmpleadoActiva
				FROM bdicred:"informix".sd_tarjeta tar
				INNER JOIN bdicred:"informix".bitacora_activacion act ON (act.numtarjeta =tar.num_tarjeta)
				WHERE tar.empresa=pEmpresa 
				AND tar.num_credito=cNumSol
				AND tar.secuencia ='1';
				
				-- SC 11092019
				SELECT LIMIT 1 NVL(eje.nombre,"")--Usuario que aperturo el crÃ?Â©dito.
				INTO cNombrePromEntrega
				FROM bdinteg:"informix".si_ejecut eje 
				WHERE eje.empresa=pEmpresa 
				AND eje.ejecutivo=cEmpleadoAsigna;
				
				-- SC 11092019
				SELECT LIMIT 1 NVL(eje.nombre,"")--Usuario que aperturo el crÃ?Â©dito.
				INTO cNombrePromActiva
				FROM bdinteg:"informix".si_ejecut eje
				WHERE eje.empresa=pEmpresa 
				AND eje.ejecutivo=cEmpleadoActiva;
				
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
		
		INSERT INTO bdicnweb:"informix".sw_cnt_detallesolcred(solicitud,cliente,fecha_sol,nom_cliente,st_sol,
		monto_sol,monto_aut,fecha_cambio_st,us_alta_sol,us_aut_sol,us_entrega_tar,us_asigna_tar,     
		tel_casa,tel_celular,tel_oficina,sucursal,nom_ref1,tel_ref1_casa,tel_ref1_celular,tel_ref1_oficina,    
		nom_ref2,tel_ref2_casa,tel_ref2_celular,tel_ref2_oficina,usuario_insert,fecha_insert) 
		VALUES(NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
         NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),
		 NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),
		 NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),NVL(cNomRef1,""),NVL(cTelefonotrabajoRef1,""),
		 NVL(cTelefonocelularRef1,""),NVL(cTelefonooficinaRef1,""),NVL(cNomRef2,""),NVL(cTelefonotrabajoRef2,""),
		 NVL(cTelefonocelularRef2,""),NVL(cTelefonooficinaRef2,""),pUsuario,CURRENT);

		LET iRecuperacion = iRecuperacion + 1;		

		LET iContBloque = iContBloque + 1;
		IF iContBloque = 5000 THEN
			LET iContBloque = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
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
	COMMIT WORK;
	
	IF bInTransaccion = 't' THEN
	 	BEGIN WORK;
	 END IF;
	
	DROP TABLE sw_cnt_detallesol_temp;
	
	IF iRecuperacion = 0 THEN
		LET cCod_ret = '00017';
	END IF;
	
	RETURN cCod_ret;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para ObtenciÃ?Â³n de datos para el reporte de solicitudes para el area de auditoria.',
'AUTOR: JesÃ?Âºs Manuel Aguilar Heredia',
'BD: bdicred ',
'FECHA: FEBERO 2014',
'VERSION: 20140217.1735',
'AUTOR: L. Montserrat León Amador',
'FECHA: 29/04/2019',
'DESCRIPCION: Se realiza spl clon para eliminar validación de REQUERIDO a los parámetros pSucursal y pStatus, y agregar nuevos parámetros de consulta pRegion y pNumCte.',
'FECHA: 02/08/2019',
'AUTOR: Miguel Huitzil C.',
'DESCRIPCION: Se modifica para regresar valores cuando campo regional es null.',
'FECHA: 11/09/2019',
'AUTOR: SANDRA CANO.',
'DESCRIPCION: Se modifica para optimizar querys de consulta.';

create procedure "informix".digverclabe_cred(pcuenta char(20))
       returning char(5),char(1);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

	DEFINE sqlerr           INTEGER; 
   
	DEFINE vcodret     		CHAR(5);
	DEFINE i,k,n,p,n1,n2 	INTEGER;
	DEFINE vdigver     		CHAR(1);
	DEFINE vctaaux     		CHAR(20);
	define vaux        		char(2);
   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************   
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret,vdigver;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO "digverclabe_cred.out";
-- TRACE ON;


	   LET vcodret = "000";
	   LET vdigver = "0";
	   LET vctaaux = pcuenta;
	   
	   
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************		   
	
		--- Obtiene el numero de posiciones, para relizar un ciclo por posicion
	   LET n = LENGTH(pcuenta);
	   LET p = 0;

		for i = 1 to n 
		
			--- Obtiene la posicion de la cadena y se recorre 1 por cada ciclo
			LET n1 = SUBSTR(vctaaux,i,1);
			
			--- Valida por posiciÃ³n de 1 a "n" , si el valor coincide lo multiplica X 3
			if i IN (1,4,7,10,13,16) then 
				let k = n1 * 3  ;
			end if;
			
			--- Valida por posiciÃ³n de 1 a "n" , si el valor coincide lo multiplica X 7
			if i IN (2,5,8,11,14,17) then 
				let k = n1 * 7  ;
			end if;
			
			--- Valida por posiciÃ³n de 1 a "n" , si el valor coincide lo multiplica X 1
			if i IN (3,6,9,12,15) then 
				let k = n1 * 1  ;
			end if;

			--- Cada valor obtenido le aplica el modelo 10, dejandolo en una solo cifra y lo acumula
			IF k >= 10 THEN LET k = MOD(k,10); END IF
				LET p = p + k;
			
		end for
	 
		--- Al total acumulado le aplica modelo 10
		LET p = MOD(p, 10);
		
		--- Si el valor de p es mayor a 0 se le resta a 10
		IF p > 0 THEN 
			LET p = 10 - p;
		END IF
		
		--- Guarda el digito verificador final
		LET vdigver = p;
		
	END;

   RETURN vcodret, vdigver;
END PROCEDURE
DOCUMENT
'GENERA DIGITO VERIFICADOR PARA CUENTA CLABE INTERBANCARIA PARA PRODUCTOS DE CREDITO',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_gen_clabe_interbancaria(pEmpresa CHAR(3), NumCredito CHAR(12),p_producto CHAR (4))
    RETURNING CHAR(6), CHAR (100);



   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
	DEFINE v_cod_ret			CHAR(6);
	DEFINE vsqlerr				INTEGER;
	DEFINE cuentaClabe			CHAR(18);

	DEFINE vcodret          	CHAR(6);
	DEFINE sqlerr           	INTEGER;
	DEFINE vctaclabecred        CHAR(18);
	DEFINE vdigverif        	CHAR(1);
	DEFINE vbanco           	CHAR(3);
	DEFINE p_cod_financiero 	CHAR (3);
	DEFINE aux_NumCredito 		CHAR(20);
	DEFINE aux_vctaclabecred 	CHAR(20);



   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret,vctaclabecred;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
	--  SET DEBUG FILE TO "/informix/Israel/sp_gen_clabe_interbancaria.out";
	--  TRACE ON;
	   
	LET vcodret    =  "000000";
	LET vctaclabecred  = " ";

	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	

		---- Consulta numero banco (clabe receptor de SPEI)
	  select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
		  FROM bdinteg:si_param
		  WHERE empresa = pempresa and cod_param = 5;

		--- Obtiene codigo de producto financiero
	   SELECT  cod_financiero INTO p_cod_financiero
		  FROM bdicred:sd_definicion
		  WHERE empresa = pempresa and num_producto = p_producto;

		   IF p_cod_financiero IS NULL OR p_cod_financiero = " " THEN
			  LET p_cod_financiero = "XXX";
		   END IF;
	   
	   --- Obtiene credito a 11 posiciones
	   LET aux_NumCredito = TRIM(SUBSTRING(NumCredito FROM 1 for 11));
	   
	   ---Arma cuenta previo 17 posiciones
	   LET aux_vctaclabecred = TRIM (vbanco || p_cod_financiero || aux_NumCredito);
	   
	   --- Proceso para generar codigo verificador
	   call digverclabe_cred(aux_vctaclabecred)
			returning vcodret, vdigverif;
			
		--- Arma cuenta final 18 posiciones
	   LET vctaclabecred = trim(aux_vctaclabecred) || vdigverif;
	   
	END;

	RETURN vcodret,vctaclabecred;

END PROCEDURE
DOCUMENT
'GENERA CUENTA CLABE INTERBANCARIA PARA PRODUCTOS DE CREDITO',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_valida_spei_cred(p_cta_clabe CHAR(18),pmonto MONEY(14,2))
RETURNING CHAR(6)       	AS retorno,
		CHAR(100)     		AS mensaje,
		CHAR (20)			AS numcte,
		CHAR (100)			AS nombre,
		CHAR (13)			AS rfc;	
		  

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet      		CHAR(6); 
DEFINE vMensaje             CHAR(300);
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;

DEFINE vbanco				CHAR (3);
DEFINE p_cod_banco			CHAR (3);
DEFINE p_cod_financiero		CHAR (3);
DEFINE p_cod_producto		CHAR (4);
DEFINE tipo_producto		INTEGER;
DEFINE v_status_cred		CHAR(2);
DEFINE v_num_credito		CHAR(20);
DEFINE v_numcte				CHAR(20);
DEFINE v_producto			CHAR (4);
DEFINE v_sucursal			CHAR (4);
DEFINE v_divisa				CHAR (2);
DEFINE v_divisa_cred		CHAR (2);
DEFINE v_transaccion		CHAR(4);
DEFINE v_Folio				CHAR(16);
DEFINE v_tipo_bloqueo		INTEGER;
DEFINE v_causa_bloqueo		CHAR (3);
DEFINE valida_total_posisiones INTEGER;
DEFINE v_validanumerico		CHAR(1);

DEFINE cCodRetGF			CHAR (3);
DEFINE cFolioSucGF			CHAR (16);

DEFINE CodRet				CHAR(5);     -- Codigo de Retorno
DEFINE g_Remanente			MONEY(14,2); -- Remanente
DEFINE g_IntMoraCob			MONEY(14,2); -- Interes Moratorio Cobrado
DEFINE g_IntVencCob			MONEY(14,2); -- Interes Vencido Cobrado
DEFINE g_CapVencCob			MONEY(14,2); -- Capital Vencido Cobrado
DEFINE g_IntVigCob			MONEY(14,2); -- Interes Vigente Cobrado
DEFINE g_CapVigCob			MONEY(14,2); -- Capital Vigente Cobrado
DEFINE g_Impuesto			MONEY(14,2); -- Impuesto Cobrado
DEFINE g_Comision			MONEY(14,2); -- Comisiones Cobradas
DEFINE g_Seguro				MONEY(14,2); -- Seguro Cobrado

DEFINE cCodRet2				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);

DEFINE v_apell_paterno		CHAR (25);
DEFINE v_apell_materno		CHAR (25);
DEFINE v_nombrecte			CHAR (100);
DEFINE v_nombre1			CHAR (25);
DEFINE v_nombre2			CHAR (25);
DEFINE v_rfc				CHAR (13);
DEFINE pempresa				CHAR (3);


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet      			= '000000';
LET vMensaje				= 'Proceso Exitoso';
LET iSqlErr      			= 0;
LET iIsamErr     			= 0;

LET vbanco					= '';
LET p_cod_banco				= '';
LET p_cod_financiero		= '';
LET p_cod_producto			= '';
LET tipo_producto			= 0;
LET v_status_cred			= '';
LET v_num_credito			= '';
LET v_numcte				= '';
LET v_producto				= '';
LET v_sucursal				= '';
LET v_divisa				= '';
LET v_divisa_cred			= '';
LET v_transaccion			= '';
LET v_Folio					= '';
LET v_tipo_bloqueo			= 0;
LET v_causa_bloqueo			= '';
LET valida_total_posisiones = 0;
LET v_validanumerico		= '';

LET cCodRetGF				= '';
LET cFolioSucGF				= '';

LET CodRet		         	= '';
LET g_Remanente	         	= 0;
LET g_IntMoraCob	     	= 0;
LET g_IntVencCob	     	= 0;
LET g_CapVencCob	     	= 0;
LET g_IntVigCob	         	= 0;
LET g_CapVigCob	         	= 0;
LET g_Impuesto	         	= 0;
LET g_Comision	         	= 0;
LET g_Seguro		     	= 0;

LET cCodRet2			= "00000";
LET cMensaje			= "Se realizÃ³ el proceso exitosamente";
LET cNumCreditocrd		= '';
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";

LET v_apell_paterno			= '';
LET v_apell_materno			= '';
LET v_nombre1				= '';
LET v_nombre2				= '';
LET v_nombrecte				= '';
LET v_rfc					= '';
LET pempresa				= '001';


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;		
				RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
			END IF;
		END EXCEPTION;
		
---	  SET DEBUG FILE TO '/informix/Israel/sp_valida_spei_cred.out';
--	  SET DEBUG FILE TO '/RESPALDOSNEW/Israel/sp_valida_spei_cred.out';
--	  TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	


		IF p_cta_clabe = '' OR p_cta_clabe IS NULL OR pmonto IS NULL OR  NVL (pmonto,'') = '' THEN
			LET cCodRet = '14';
			LET vMensaje = 'Falta informaciÃ³n mandatoria para completar el pago';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;
		
		--- Obtiene el numero de posiciones
		LET valida_total_posisiones = LENGTH(p_cta_clabe);
		
		--- Valida que la cadena sea solo numerica
		EXECUTE PROCEDURE bdinteg:sp_esnumerico (p_cta_clabe)
			INTO v_validanumerico;
		
		---- Consulta numero banco (clabe receptor de SPEI)
		select{+ INDEX(bdinteg:si_param ix_si_param)} valor INTO vbanco
		  FROM bdinteg:si_param
		  WHERE empresa = pempresa and cod_param = 5;

		--- Obtiene codigo Bancario
		LET p_cod_banco = SUBSTR(p_cta_clabe,1,3);
		--- Obtiene codigo financiero
		LET p_cod_financiero = SUBSTR(p_cta_clabe,4,3);
		--- Obtiene numero de producto
		LET p_cod_producto = SUBSTR(p_cta_clabe,7,2)||'00';
			
		IF NVL (p_cod_banco,'') <> vbanco THEN
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF pmonto <= 0 THEN
			LET cCodRet = '15';
			LET vMensaje = 'Tipo de pago erroneo';	
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF p_cod_producto = '6500' OR valida_total_posisiones <> 18 THEN
			LET cCodRet = '17';
			LET vMensaje = 'Tipo de cuenta no corresponde';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		ELIF v_validanumerico = 'F' THEN
			LET cCodRet = '19';
			LET vMensaje = 'Caracter invalido';		
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
		END IF;	
				
		IF p_cod_financiero in ('975') OR p_cod_producto = '7800' THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,a.id_unidad_prod,a.Cod_caract_2,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_tipo_bloqueo,v_causa_bloqueo,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecred a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF (v_tipo_bloqueo <> '' OR v_tipo_bloqueo IS NOT NULL) 
--					AND (v_causa_bloqueo <> '' OR v_causa_bloqueo IS NOT NULL) THEN --- VALIDAR ESTATUS BLOQUEADO
--						LET cCodRet = '2';
--						LET vMensaje = 'Cuenta Bloqueada';
--						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('FI','FF') THEN --- Validar tipos de canceladas FI cancelada por saldos inmateriales
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE

					EXECUTE PROCEDURE bdicred:"informix".principalrefer (pempresa,v_num_credito,1,'',user,v_sucursal,cFolioSucGF,v_transaccion,0,pmonto,'')
						INTO CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob,
							g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto,
							g_Comision, g_Seguro;
							
						IF (CodRet::INTEGER <> 0) THEN
							LET cCodRet = '000448';
							LET vMensaje = 'Error al ejecutar el pago';
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
								
						END IF;
				END IF;

		ELIF p_cod_financiero in ('970','971','972') THEN
		
			SELECT a.num_credito,a.numcte,a.num_producto,a.status_cred,a.sucursal,a.divisa,b.divisa,b.transacc_spei
				INTO v_num_credito,v_numcte,v_producto,v_status_cred,v_sucursal,v_divisa_cred,v_divisa,v_transaccion
			FROM  bdicred:"informix".sd_maecredcrd a
				JOIN bdicred:sd_definicion b on (a.num_producto = b.num_producto)
				WHERE cuenta_clabe = p_cta_clabe;
				
				IF (v_num_credito IS NULL OR NVL (v_num_credito,'') = '') OR (v_numcte IS NULL OR NVL (v_numcte,'') = '') 
					OR (v_producto IS NULL OR NVL (v_producto,'') = '') THEN
						LET cCodRet = '1';
						LET vMensaje = 'Cuenta Inexistente';
						RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

--				ELIF v_status_cred = '' THEN --- VALIDAR ESTATUS BLOQUEADO
--					LET cCodRet = '2';
--					LET vMensaje = 'Cuenta Bloqueada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--
--				ELIF v_status_cred IN ('CN','FF') THEN --- 
--					LET cCodRet = '3';
--					LET vMensaje = 'Cuenta Cancelada';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
--					
--				ELIF (NVL (v_divisa_cred,'') = '' OR v_divisa_cred IS NULL) OR  v_divisa <> v_divisa_cred THEN 
--					LET cCodRet = '5';
--					LET vMensaje = 'Cuenta en otra divisa';
--					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				END IF;
			--- Genera folio para el movimiento
			EXECUTE PROCEDURE bdicred:sp_generafoliocredi(user ,1)
			INTO cCodRetGF,cFolioSucGF;
			
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000447';
					LET vMensaje = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
				ELSE

					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr (pempresa,v_num_credito,v_producto,pmonto,0,user,v_sucursal,cFolioSucGF,v_transaccion)
						INTO cCodRet2,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,
							Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;
							
						IF (cCodRet2::INTEGER <> 0) THEN
							LET cCodRet = '000449';
							LET vMensaje = cMensaje;
							RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;
						ELSE
							SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
								INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_rfc
							FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF v_nombre2 IS NULL OR NVL (v_nombre2,'') = '' THEN
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							ELSE
								LET v_nombrecte = TRIM (v_nombre1)||' '||TRIM (v_nombre2)||' '||TRIM (v_apell_paterno)||' '||TRIM (v_apell_materno);
							END IF;
							
						END IF;
				END IF;
		ELSE
			LET cCodRet = '6';
			LET vMensaje = 'Cuenta no pertenece al Banco Receptor';
			RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;		
		END IF;
		
	END		
	
RETURN cCodRet,vMensaje,v_numcte,v_nombrecte,v_rfc;

END PROCEDURE
DOCUMENT
'Proceso que realiza la validacion para aplicar un SPEI de credito',
'AUTOR : Israel Travieso',
'FECHA : SEP/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".respaldacrd(eEmpresa    CHAR(3),
                                        eNumCredito CHAR(20),
                                        eFolio      CHAR(20))
   RETURNING CHAR(5);   --CodRet


   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);

   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;

   DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';
   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';

   LET CodRet = "000";
   SELECT MAX(secuencia)
     INTO wSecuenciaPago
     FROM sd_secpago
    WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito;

--set debug file to "respaldacredito.out";
--trace on;


  LET g_NumCredito = eNumCredito;
  LET g_Folio      = eFolio;
  LET g_Empresa    = eEmpresa;

   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN
      LET wSecuenciaPago = 0;
   END IF;

   LET wSecuenciaPago = wSecuenciaPago + 1;

   INSERT INTO
      sd_secpago (empresa, num_credito, folio_suc, secuencia)
   VALUES
      (g_empresa, g_NumCredito, g_Folio, wSecuenciaPago);

                             --**    Respalda Maecred                          --
   INSERT INTO sd_maecredrev
        (empresa           , num_credito     , folio           , num_producto    , ejecutivo          ,
         numcte            , divisa          , sucursal        , id_origen       , origen             ,
         cod_tipo_linea    , cod_linea       , porc_rec_prop   , status_cred     , bandera_renovac    ,
         bandera_prorroga  , periodo_plazo   , plazo           , fecha_apertura  , fecha_vencim       ,
         period_pago_cap   , period_pag_int  , dias_trasp_cap  , dias_trasp_int  , tasa_fija_o_var    ,
         cod_tasa_base     , factor_sobretasa, sobretasa       , tasa_interes    , cod_tasa_mora      ,
         sobretasa_mora    , fact_sobret_mora, tasa_moratorios , fecha_pago_cap  , fecha_pago_int     ,
         es_fisica         , bandera_fi_fo   , codigo_pro      , superficie      , actividad          ,
         cal_edos_fin      , tipo_calculo    , admite_tlp      , rel_garcred     , id_unidad_prod     ,
         num_aper_ant      , rev_tasa_var_per, dia_para_revisar, cod_prod        , bandera_ministra   ,
         num_fideicomiso   , credito_externo , gracia_capital  , diferimiento_int, fecha_fin_prorrateo,
         campo_trab1       , campo_trab2     , campo_trab3     , campo_trab4     , calificacion_riesgo,
         cod_agricola      , tasa_base_piso  , sobretasa_piso  , factor_piso     , tasa_piso          ,
         tasa_base_techo   , sobretasa_techo , factor_techo    , tasa_techo      , cod_caract         ,
         cod_caract_2	   , cuenta_clabe)
   SELECT
        empresa            , num_credito     , g_folio         , num_producto    , ejecutivo         ,
         numcte            , divisa          , sucursal        , id_origen       , origen             ,
         cod_tipo_linea    , cod_linea       , porc_rec_prop   , status_cred     , bandera_renovac    ,
         bandera_prorroga  , periodo_plazo   , plazo           , fecha_apertura  , fecha_vencim       ,
         period_pago_cap   , period_pag_int  , dias_trasp_cap  , dias_trasp_int  , tasa_fija_o_var    ,
         cod_tasa_base     , factor_sobretasa, sobretasa       , tasa_interes    , cod_tasa_mora      ,
         sobretasa_mora    , fact_sobret_mora, tasa_moratorios , fecha_pago_cap  , fecha_pago_int     ,
         es_fisica         , bandera_fi_fo   , codigo_pro      , superficie      , actividad          ,
         cal_edos_fin      , tipo_calculo    , admite_tlp      , rel_garcred     , id_unidad_prod     ,
         num_aper_ant      , rev_tasa_var_per, dia_para_revisar, cod_prod        , bandera_ministra   ,
         num_fideicomiso   , credito_externo , gracia_capital  , diferimiento_int, fecha_fin_prorrateo,
         campo_trab1       , campo_trab2     , campo_trab3     , campo_trab4     , calificacion_riesgo,
         cod_agricola      , tasa_base_piso  , sobretasa_piso  , factor_piso     , tasa_piso          ,
         tasa_base_techo   , sobretasa_techo , factor_techo    , tasa_techo      , cod_caract         ,
         cod_caract_2	   , cuenta_clabe
    FROM sd_maecred
   WHERE num_credito = g_NumCredito
   AND   empresa = g_Empresa;

                             --**    Respalda Maesdos      --

   INSERT INTO sd_maesdosrev
         (empresa            , num_credito         , folio            , fecha_ult_mov     , sdo_int_anticip  ,
          sdo_int_ant_dev    , sdo_intereses       , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido       , sdo_acum_cap_int    , sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int      , sdo_moratorio       , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora     , sdo_capital         , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap   , mto_capitalizado    , mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap     , abonos_mes_cap      , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado   , monto_reservado     , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper    , monto_otorgado      , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int       , mto_venc_tra_int    , mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp  , int_tra_no_exig     , sdo_trab4        )
   SELECT
          empresa            , num_credito         , g_Folio          ,  fecha_ult_mov    , sdo_int_anticip   ,
          sdo_int_ant_dev    , sdo_intereses       , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido       , sdo_acum_cap_int    , sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int      , sdo_moratorio       , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora     , sdo_capital         , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap   , mto_capitalizado    , mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap     , abonos_mes_cap      , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado   , monto_reservado     , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper    , monto_otorgado      , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int       , mto_venc_tra_int    , mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp  , int_tra_no_exig     , sdo_trab4
   FROM sd_maesdos
   WHERE empresa   = g_Empresa
   AND num_credito = g_NumCredito;


                             --**    Respalda MaecredAnexo --
   INSERT INTO sd_maecredanexorev
        (empresa            , num_credito       ,  folio, dia_corte , dias_gracia_mora    , tp_dias_calc_mora,
         dias_fecha_max_pago, tp_dias_fecha_pago,  cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte    ,
         tasa_interes_cte   , fecha_vencto      ,  prox_fecha_pago  , fecha_proceso       , fecha_ult_pago  )
   SELECT
        empresa             , num_credito       ,  g_Folio,  dia_corte,  dias_gracia_mora , tp_dias_calc_mora,
         dias_fecha_max_pago, tp_dias_fecha_pago,  cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte    ,
         tasa_interes_cte   , fecha_vencto      ,  prox_fecha_pago  , fecha_proceso       , fecha_ult_pago
  FROM sd_maecredanexo
  WHERE empresa     = g_Empresa
    AND num_credito = g_NumCredito;

                             --**    Respalda AmortizaCredito --

  INSERT INTO sd_amortiza_creditorev(
       empresa                , folio            , num_credito            , fecha_cuota            , tipo_cuota             ,
       capital_mto_cuota      , capital_debe     , capital_pagado         , capital_status         , capital_status_ant     ,
       capital_fecha_pago     , interes_debe     , interes_pagado         , interes_status         , interes_status_ant     ,
       interes_fecha_pago     , iva_debe         , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi  , mora_provi_cope        , mora_sdo_ordi          , mora_sdo_ordi_pag      ,
       mora_sdo_cope          , mora_sdo_cope_pag, mora_bonificado        , mora_status            , mora_iva_debe          ,
       mora_iva_pagado        , mora_iva_status  , mora_iva_fecha_pago    , num_pago               , campo_trabajo1         ,
       campo_trabajo2         , campo_trabajo3   , campo_trabajo4         )
  SELECT
       empresa                , g_folio          , num_credito            , fecha_cuota            , tipo_cuota             ,
       capital_mto_cuota      , capital_debe     , capital_pagado         , capital_status         , capital_status_ant     ,
       capital_fecha_pago     , interes_debe     , interes_pagado         , interes_status         , interes_status_ant     ,
       interes_fecha_pago     , iva_debe         , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi  , mora_provi_cope        , mora_sdo_ordi          , mora_sdo_ordi_pag      ,
       mora_sdo_cope          , mora_sdo_cope_pag, mora_bonificado        , mora_status            , mora_iva_debe          ,
       mora_iva_pagado        , mora_iva_status  , mora_iva_fecha_pago    , num_pago               , campo_trabajo1         ,
       campo_trabajo2         , campo_trabajo3   , campo_trabajo4
 FROM sd_amortiza_credito
 WHERE empresa     = g_empresa
   ANd Num_credito = g_numcredito;

   RETURN CodRet;

END PROCEDURE
;
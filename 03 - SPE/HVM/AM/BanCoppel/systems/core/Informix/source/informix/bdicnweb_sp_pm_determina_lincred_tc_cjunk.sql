CREATE PROCEDURE "informix".sp_pm_determina_lincred_tc_cjunk(pUsuario CHAR(8), pIdFuncion CHAR(10),pEmpresa CHAR(3), pNumSol CHAR(20), pCteNvo CHAR(1))
		RETURNING CHAR(5) AS codret,
				  MONEY(14,2) AS linea_cred,
				  MONEY(14,2) AS capacidad_de_pago,
				  INTEGER AS plazo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE mLinCred MONEY(14,2);
	DEFINE mCapPago MONEY(14,2);
	DEFINE iPlazo INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET mLinCred = 0.0;
	LET mCapPago = 0.0;
	LET iPlazo = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_determina_lincred_tc_cjunk.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pEmpresa, pNumSol, pCteNvo) 
		INTO cCodRet,mLinCred,mCapPago,iPlazo;
        
        IF cCodRet = '000' THEN
            LET cCodRet ='00000';
        END IF;
        
		RETURN cCodRet,mLinCred,mCapPago,iPlazo;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio de estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo determina_lincred_tc_cjunk',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_consultaempleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS existe;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cExiste CHAR(1);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cExiste = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cExiste;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_consultaempleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cExiste;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cExiste;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
        SELECT COUNT(*) INTO iExiste FROM bdisolic:ss_emp_revingresos_mc WHERE num_empleado = pUsuario;
		
		IF iExiste = 0 THEN 
			LET cExiste='0';
		END IF;
		
		IF iExiste >= 1 THEN 
			LET cExiste='1';
		END IF;
		
		RETURN cCodRet,cExiste;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de consultar si el empleado existe en la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_consulparam_cambioestatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(50) as valor,
				  CHAR(1) as estatus;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(50);
	DEFINE cEstatus CHAR(1);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor ='';
	LET cEstatus ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cValor,cEstatus;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_consulparam_cambioestatus.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cValor,cEstatus;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cValor,cEstatus;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   		
		SELECT valor,estatus INTO cValor,cEstatus FROM bdisolic:"informix".ss_paramcambioestatus WHERE descrip_param  = 'Tiempo_Limite' AND tipo_param ='P';
       
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cValor,cEstatus;
		END IF;		
	   
		RETURN cCodRet,cValor,cEstatus;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Monitor solicitudes',
'DESCRIPCION: SPL encargado de recuperar datos de la tabla ss_paramcambioestatus',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_cons_empleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(60)	AS nom_emp;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomEmp CHAR(60);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomEmp = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNomEmp;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_cons_empleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNomEmp;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNomEmp;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
        FOREACH
        EXECUTE PROCEDURE bdisolic:"informix".sp_cons_empleado_mc(pNumEmpleado) INTO cNomEmp 
        RETURN cCodRet,cNomEmp WITH RESUME;
        END FOREACH;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_cons_empleado_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_califica_scoring2_cjunk(pUsuario CHAR(8), pIdFuncion CHAR(10),pEmpresa CHAR(3), pNumSol CHAR(20))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;  
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_califica_scoring2_cjunk.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pNumSol ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;  
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;  
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk(pEmpresa, pNumSol) INTO cCodRet; 

        IF cCodRet = '000' THEN
            LET cCodRet ='00000';
        END IF;
        
		RETURN cCodRet;  
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo califica_scoring2_cjunk',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitorconsultatotsolicitudxmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(100), pTipo SMALLINT)
	RETURNING CHAR(5) AS codret,
		INTEGER AS total_regs;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaInsert DATE;
	DEFINE dFechaModificacion DATE;
	DEFINE mMontoSolicitado DECIMAL(18,2);
	DEFINE mEficiencia DECIMAL(18,2);
	DEFINE iHistorial SMALLINT;
	DEFINE cStatusInicial CHAR(2);
	DEFINE mSeccion1 DECIMAL(18,2);
	DEFINE mSeccion2 DECIMAL(18,2);
	DEFINE cCausaSolic CHAR(3);
	DEFINE cObservaciones CHAR(300);
	DEFINE cNumProducto CHAR(4);
	DEFINE cStatusFin CHAR(2);
	DEFINE cEjecutivoAtiende CHAR(8);
	DEFINE cEjcutivoAutoriza CHAR(8);
	DEFINE dHoraInsert DATETIME HOUR TO SECOND;
	DEFINE dFechaDeterminacion DATE;
	DEFINE cRevisado CHAR(1);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegs INTEGER;
	DEFINE iNoRegs INTEGER;

	-- InicializaciÃ³n de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaInsert = NULL;
	LET dFechaModificacion = NULL;
	LET mMontoSolicitado = NULL;
	LET mEficiencia = NULL;
	LET iHistorial = 0;
	LET cStatusInicial = '';
	LET mSeccion1 = NULL;
	LET mSeccion2 = NULL;
	LET cCausaSolic = '';
	LET cObservaciones = '';
	LET cNumProducto = '';
	LET cStatusFin = '';
	LET cEjecutivoAtiende = '';
	LET cEjcutivoAutoriza = '';
	LET dHoraInsert = NULL;
	LET dFechaDeterminacion = NULL;
	LET cRevisado = '';
	LET cEmpresa = '001';
	LET iTotalRegs = 0;
	LET iNoRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegs;
		END EXCEPTION;
		
		ON EXCEPTION IN (-239)
			LET cCodRet = '00017';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_monitorconsultatotsolicitudxmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pTipo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		-- ValidaciÃ³n del tipo de busqueda
		IF pTipo NOT IN (1,2,3) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		IF pTipo = 3 THEN
			IF pEjecutivoAtiende = '' OR pNumSolicitud = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegs;
			ENd IF;
			
			IF pStatus IN ('CM', 'RT') AND pCausa = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegs;
			END IF;
		END IF;
		
		-- ValidacciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;	

		-- Conteo del numero de registros
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultaactualizasolicmc(cEmpresa, pNumSolicitud, pEjecutivoAtiende, pStatus, pCausa, pObservaciones, pTipo)
			INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0 , 'ERROR EN LA EJECUCION DEL SP PRODUCTIVO bdisolic:sp_consultaactualizasolicmc';
				ELIF cCodRetSp::INTEGER = 0 THEN
					LET iTotalRegs = iTotalRegs + 1;
				ELIF cCodRetSp = '00001' THEN -- Parametros incorrectos
					LET cCodRet = '00003';
					RETURN cCodRet, iTotalRegs;
				ELIF cCodRetSp = '00002' THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD
					LET cCodRet = '00219';
					RETURN cCodRet, iTotalRegs;
				ELIF cCodRetSp IN ('00003', '00004', '00005') THEN -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS
					LET cCodRet = '00220';
					RETURN cCodRet, iTotalRegs;
				END IF;
				
		END FOREACH;
		
		IF iTotalRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		RETURN cCodRet, iTotalRegs;

	END;
END PROCEDURE
DOCUMENT "AUTOR: Johnattan Esquivel Sanchez",
"FECHA: 12/03/2020",
"MODIFICACION: Se se modifica procedimiento por control de excepcion",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_monitorconsultasolicitudxmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(100), pTipo SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		CHAR(100) AS nombre_cliente,
		CHAR(13) AS rfc,
		CHAR(4) AS sucursal,
		DATE AS fecha_insert,
		DATE AS fecha_modificacion,
		DECIMAL(18,2) AS monto_solicitado,
		DECIMAL(18,2) AS eficiencia,
		SMALLINT AS historial,
		CHAR(2) AS status_inicial,
		DECIMAL(18,2) AS seccion1,
		DECIMAL(18,2) AS seccion2,
		CHAR(3) AS causa_solic,
		CHAR(300) AS observaciones,
		CHAR(4) AS num_producto,
		CHAR(2) AS status_fin,
		CHAR(8) AS ejecutivo_atiende,
		CHAR(8) AS ejecutivo_autoriza,
		DATETIME HOUR TO SECOND AS hora_insert,
		DATE AS fecha_determinacion,
		CHAR(1) AS revisado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaInsert DATE;
	DEFINE dFechaModificacion DATE;
	DEFINE mMontoSolicitado DECIMAL(18,2);
	DEFINE mEficiencia DECIMAL(18,2);
	DEFINE iHistorial SMALLINT;
	DEFINE cStatusInicial CHAR(2);
	DEFINE mSeccion1 DECIMAL(18,2);
	DEFINE mSeccion2 DECIMAL(18,2);
	DEFINE cCausaSolic CHAR(3);
	DEFINE cObservaciones CHAR(300);
	DEFINE cNumProducto CHAR(4);
	DEFINE cStatusFin CHAR(2);
	DEFINE cEjecutivoAtiende CHAR(8);
	DEFINE cEjcutivoAutoriza CHAR(8);
	DEFINE dHoraInsert DATETIME HOUR TO SECOND;
	DEFINE dFechaDeterminacion DATE;
	DEFINE cRevisado CHAR(1);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegs INTEGER;
	DEFINE iNoRegs INTEGER;

	-- Inicialización de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaInsert = NULL;
	LET dFechaModificacion = NULL;
	LET mMontoSolicitado = NULL;
	LET mEficiencia = NULL;
	LET iHistorial = 0;
	LET cStatusInicial = '';
	LET mSeccion1 = NULL;
	LET mSeccion2 = NULL;
	LET cCausaSolic = '';
	LET cObservaciones = '';
	LET cNumProducto = '';
	LET cStatusFin = '';
	LET cEjecutivoAtiende = '';
	LET cEjcutivoAutoriza = '';
	LET dHoraInsert = NULL;
	LET dFechaDeterminacion = NULL;
	LET cRevisado = '';
	LET cEmpresa = '001';
	LET iTotalRegs = 0;
	LET iNoRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_monitorconsultasolicitudxmc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pTipo IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		-- Validación del tipo de busqueda
		IF pTipo NOT IN (1,2,3) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		IF pTipo = 3 THEN
			IF pEjecutivoAtiende = '' OR pNumSolicitud = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
					mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
					cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
			ENd IF;
			
			IF pStatus IN ('CM', 'RT') AND pCausa = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
					mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
					cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
			END IF;
		END IF;
		
		-- Validacción de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtención de datos
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultaactualizasolicmcsoc(cEmpresa, pNumSolicitud, pEjecutivoAtiende, pStatus, pCausa, pObservaciones, pTipo, pRegistros, pRecuperacion,pUsuario)
			INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado
				
				IF cCodRetSp::INTEGER = 0 THEN
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado WITH RESUME;
				ELIF cCodRetSp = '00001' THEN -- Parametros incorrectos
					LET cCodRet = '00003';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				ELIF cCodRetSp = '00002' THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD
					LET cCodRet = '00219';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				ELIF cCodRetSp IN ('00003', '00004', '00005') AND pRegistros = 0 THEN -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS
					LET cCodRet = '00220';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				END IF;
				
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
	END;
END PROCEDURE;
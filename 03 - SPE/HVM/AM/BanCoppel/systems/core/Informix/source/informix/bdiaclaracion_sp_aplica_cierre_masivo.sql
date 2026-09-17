CREATE PROCEDURE "informix".sp_aplica_cierre_masivo(pFolio CHAR(16), pProcede CHAR(1), pResolucion INTEGER, pOpcion CHAR(1), 
													pEmpleado CHAR (8), pPreDictamen VARCHAR(250), pNumProceso INTEGER, pafectacion CHAR(1))
RETURNING CHAR(6), CHAR (11), CHAR (50);

    DEFINE cCodRet              CHAR(6);	--
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
	DEFINE CMensaje             CHAR(80);

    DEFINE vFolioCsuac			CHAR(11);
	DEFINE vResultado			CHAR(50);
	DEFINE vFechaActual         DATETIME YEAR to FRACTION(5);
	DEFINE vFechaDictamen		DATETIME YEAR to FRACTION(5);
	
	DEFINE wBegin               CHAR(1);
	
	DEFINE vIDAclaracion		INTEGER;
	DEFINE vEstatusAclInicial	INTEGER;
	DEFINE vEstatusCorpInicial	INTEGER;
	DEFINE vEstatusAnaInicial	INTEGER;
	DEFINE vFechaCapturaAcl		DATE;
	DEFINE vAreaAcl				INTEGER;
	DEFINE vEstatusAcl			INTEGER;
	DEFINE vEstatusCorp			INTEGER;
	DEFINE vEstatusAna			INTEGER;
	
	DEFINE vPredictamenEstatusCorp INTEGER;
	DEFINE vAccionPredictamen	INTEGER;
	DEFINE vImporteReclamado	MONEY;
	DEFINE vCostoComision		MONEY;
	DEFINE vIDUsusario			INTEGER;
	
	DEFINE vAccionAbono			INTEGER;
	DEFINE vAbonoTemporal		INTEGER;
	DEFINE vIndicadorAfectacion	INTEGER;
		
	DEFINE vAfectacion			CHAR(2);
	DEFINE vTipoProducto		CHAR(1);
	DEFINE cAccionAfectacion	CHAR(25);
	DEFINE cAccionNoAfectacion	CHAR(25);
	DEFINE vAccionAfectacion	INTEGER;
	DEFINE vDescAfectacion		CHAR(200);
	DEFINE vAccionDictamen		INTEGER;
	DEFINE vDescDictamen		CHAR(200);
	DEFINE vDescSMS				CHAR(200);
	DEFINE vAccionSMS			INTEGER;
	DEFINE vDescCorreo			CHAR(200);
	DEFINE vAccionCorreo		INTEGER;
	
	DEFINE vDictamen			CHAR(2);
	DEFINE vCodRetAfectacion	CHAR(3);
	
	DEFINE vDictamenEstatusCorp INTEGER;
	DEFINE vDictamenEstatusAcl 	INTEGER;
	DEFINE vDiasConclusion		INTEGER;
	
	--Variables de notificaciones
	DEFINE vCodretNotif 		CHAR(5);
	DEFINE vCliente				CHAR(9);
	DEFINE vNombreCliente		CHAR(150);
	DEFINE vNombre1 			CHAR(50);
	DEFINE vNombre2 			CHAR(50);
	DEFINE vApellPaterno 		CHAR(50);
	DEFINE vApellMaterno 		CHAR(50);
	DEFINE vcodretDatosCte 		CHAR(5);
	DEFINE vCorreoElec 			CHAR(100);
	DEFINE vTipoCorreo 			SMALLINT;
	DEFINE vStatusCorreo 		CHAR(1);
	
	DEFINE vTelefono 			CHAR(13);
	DEFINE vTipoTel 			SMALLINT;
	DEFINE vSecuencia 			SMALLINT;
	DEFINE vStatus_Tel 			CHAR(1);
	DEFINE vExtension 			CHAR(5);
	DEFINE vCarrier 			SMALLINT;
	DEFINE vNombreCarrier 		CHAR(20);
	DEFINE StatusValidacion 	SMALLINT;
	
	DEFINE vTipoDictamen		VARCHAR(15);
	DEFINE vCuenta				VARCHAR(20);  -- PEHY
	DEFINE vCuentaEnmascarada	VARCHAR(20);   --PEHY
	DEFINE vPreDictamen1		VARCHAR(100);
	DEFINE vPreDictamen2		VARCHAR(100);
	DEFINE vPreDictamen3		VARCHAR(60);
	DEFINE vHoraDictamen		CHAR(10);
	DEFINE vFechaNotifacion		CHAR(15);
	
	--Declaracion de Constantes para los envios de notificaciones
	DEFINE cContratoCorreo 		CHAR(10);
	DEFINE cContratoSMS 		CHAR(10);
	DEFINE cPlantilla 			CHAR(12);
	--------
	DEFINE vDescripcionAccion  	VARCHAR(250);
	DEFINE vAccionInicioCierre 	INTEGER;
	DEFINE v_producto			INTEGER;
	
	DEFINE cContratoNotCoppel       	CHAR(10);
	DEFINE cPlantillaSMSCoppelPro     	CHAR(12);
	DEFINE cPlantillaSMSCoppelNoPro   	CHAR(12);
	DEFINE cPlantillaCorreoCoppel	  	CHAR(12);
	
	DEFINE v_nombre						CHAR(60);
	DEFINE v_apellidos					CHAR(70);
	
	DEFINE v_procedio					CHAR(20);
	DEFINE v_desprocedente 				CHAR(20);
	
	--Inicializacion de Variables
	LET cCodRet      			= '000';
	LET wBegin 					= 'N';
	LET vFolioCsuac 			= NULL;
	LET vResultado 				= NULL;
	LET vEstatusAclInicial		= NULL;
	LET vEstatusCorpInicial		= NULL;
	LET vEstatusAnaInicial		= NULL;
	LET vEstatusAcl				= NULL;
	LET vEstatusCorp			= NULL;
	LET vEstatusAna				= NULL;
	
	LET vIDAclaracion			= NULL;
	LET vPredictamenEstatusCorp = NULL;
	LET vAccionPredictamen		= NULL;
	LET vImporteReclamado		= 0.00;
	LET vCostoComision			= 0.00;
	LET vIDUsusario				= 0;
	LET vAfectacion				= 'No';
	LET vAccionAbono			= 3;
	LET vDescDictamen			= NULL;
	
	LET vAbonoTemporal			= 0;
	LET vIndicadorAfectacion	= 0;
	LET vTipoProducto			= NULL;
	
	LET vDictamen				= NULL;
	LET vCodRetAfectacion		= NULL;
	LET cAccionNoAfectacion		= 'noAfectacionMovimiento';
	LET cAccionAfectacion		= 'afectacionMovimiento';
	
	LET vDictamenEstatusCorp 	= NULL;
	LET vDictamenEstatusAcl 	= NULL;
	LET vDiasConclusion			= NULL;
	
	LET vTipoDictamen			= NULL;
	LET vTelefono 				= NULL;
	LET vCorreoElec 			= NULL;
	LET vCodretNotif 			= NULL;
	LET vNombreCliente 			= NULL;
	LET vDescSMS				= NULL;
	LET vDescCorreo				= NULL;
	
	
	LET vPreDictamen1 			= NULL;
	LET vPreDictamen2 			= NULL;
	LET vPreDictamen3 			= NULL;
	LET vHoraDictamen 			= NULL;
	LET vFechaNotifacion 		= NULL;
	LET vCuentaEnmascarada		= NULL;
	LET vDescripcionAccion		= NULL;
	LET vAccionInicioCierre		= NULL;
	
	--Inicializacion Constantes
	LET cContratoCorreo 		= 'ACL_EMAIL';
	LET cContratoSMS 			= 'ACL_SMS';
	LET cPlantilla 				= 'ACL_SMS';
	---
	LET v_producto				= NULL;
	
	LET cContratoNotCoppel       		= 'ACL_CPPL';
	LET cPlantillaSMSCoppelPro    	 	= 'SM_COPPEL_D1';
	LET cPlantillaSMSCoppelNoPro  	 	= 'SM_COPPEL_D2';
	LET cPlantillaCorreoCoppel			= 'EM_COPPEL_DI';
	LET v_apellidos						= '';
	LET v_nombre						= '';
	
	LET v_procedio						= '';
	LET v_desprocedente 				= '';
	
BEGIN

	ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET cCodRet = sql_err;
		--ROLLBACK WORK;
		IF vResultado IS NULL THEN
			LET vResultado = 'Proceso Fallido';
		ELSE
			LET vResultado = TRIM(vResultado) || '-' || 'Proceso Fallido';
		END IF;
		
		
		IF ((SELECT 1 FROM acl_cierre_masivo WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual) = 1) THEN
			UPDATE acl_cierre_masivo SET 
				proceso = vResultado
			WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
		ELSE
			INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
				VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAcl, vEstatusAna, vEstatusCorp, vAfectacion, vResultado, pNumProceso);
		END IF
			
		RETURN cCodRet, vFolioCsuac, vResultado;
	END EXCEPTION;
	ON EXCEPTION IN (-535)
			  
			  COMMIT WORK;
				
	END EXCEPTION WITH RESUME;

	SELECT current 
		INTO vFechaActual 
	FROM systables WHERE tabid = 1;

	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
	--SET DEBUG FILE TO "/resplogifx/traces/sp_aplica_cierre_masivo_CAN"||"_"||""||TRIM(pFolio)||""||".out";
	--TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   
	SELECT pky_resolucion, descripcion
		INTO vAccionInicioCierre, vDescripcionAccion
	FROM acl_resolucion
	WHERE nombre = 'iniciocierreMasivo';
	
	SELECT pky_usuario 
		INTO vIDUsusario
	FROM acl_usuario
	WHERE num_empleado = pEmpleado and pky_usuario='1';
   
   --Obtencion del Folio_CSUAC dependiendo el tipo de archivo
	IF (pOpcion = 1) THEN
		
		SELECT folio_csuac
			INTO vFolioCsuac
		FROM acl_aclaracion
		WHERE folio_csuac = pFolio;
		
		IF (vFolioCsuac IS NULL) THEN
			LET vResultado = 'Folio Inexistente';
			LET cCodRet = '001';
			
			INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
				VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vAfectacion, vResultado, pNumProceso);
			
			RETURN cCodRet, NULL, vResultado;
		END IF;
	ELIF (pOpcion = 2) THEN
		SELECT mov.folio_csuac
			INTO vFolioCsuac
		FROM acl_movimiento mov
			INNER JOIN acl_aclaracion acl ON fky_aclaracion = pky_aclaracion 
				AND fky_estatus_aclaracion BETWEEN 2 AND 5
		WHERE folio_suc = pFolio
			AND fky_padre IS NULL
			AND duplicado = 0;
		
		IF (vFolioCsuac IS NULL) THEN
			LET vResultado = 'Folio Inexistente';
			LET cCodRet = '001';
			
			INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
				VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vAfectacion, vResultado, pNumProceso);
			
			RETURN cCodRet, NULL, vResultado;
		END IF;
	ElSE
		LET vResultado = 'OpciÃÂÃÂ³n Incorrecta';
		LET cCodRet = '002';
		INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
			VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vAfectacion, vResultado, pNumProceso);
		
		RETURN cCodRet, NULL, vResultado;
	END IF;
	
	--Extraccion de variables de la Informacion Inicial del Folio_CSUAC
	SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, pky_aclaracion, fky_area, importereclamado, fechacaptura, 
			num_cliente
		INTO vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vIDAclaracion, vAreaAcl, vImporteReclamado, vFechaCapturaAcl, 
			vCliente
	FROM acl_aclaracion
	WHERE folio_csuac = vFolioCsuac;
	
	--Se registra en bitacora que se inica el proceso de cierre masivo
	IF vAccionInicioCierre IS NOT NULL THEN
		LET vDescripcionAccion = TRIM(vDescripcionAccion)||': '||vFolioCsuac;
		
		INSERT INTO acl_entrada_bitacora 
			(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
				fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
		VALUES(entrada_bitacora_seq.nextval, vDescripcionAccion, current, vFolioCsuac, vAccionInicioCierre, vIDAclaracion, vAreaAcl, 
			vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vIDUsusario);
		
	END IF;
	
	IF vEstatusAclInicial >= 3 THEN 
		LET vResultado = 'Cerrado Previamente';
		LET cCodRet = '003';
		
		INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
			VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vAfectacion, vResultado, pNumProceso);
		
		RETURN cCodRet, vFolioCsuac, vResultado;
	END IF;
	
	--Se realiza el Predictamen del Folio_CSUAC
	
	SELECT pky_estatus_corporativo, fky_accion
		INTO vPredictamenEstatusCorp, vAccionPredictamen
	FROM acl_estatus_corporativo 
	WHERE nombre = 'PREDICTAMINADA' AND activo = 1;
	
	LET pPreDictamen = replace(replace(pPreDictamen,chr(13),''),chr(10),'');
	--Se actualiza el Folio a Predictaminado
	UPDATE acl_aclaracion SET 
		Montoprocedente = vImporteReclamado,
		Predictamen = pPreDictamen,
		Procede = pProcede,
		fky_estatus_corp_general = vPredictamenEstatusCorp,
		fky_tipo_codigo_resolucion = pResolucion
	WHERE folio_csuac = vFolioCsuac;
	
	--Se Registra el predictamen en la tabla de control
	SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general
		INTO vEstatusAcl, vEstatusAna, vEstatusCorp
	FROM acl_aclaracion
	WHERE folio_csuac = vFolioCsuac;
	
	LET vResultado = 'Predictaminado';
	
	INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
		VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAcl, vEstatusAna, vEstatusCorp, vAfectacion, vResultado, pNumProceso);
	
	--Se registra el predictamen en la bitacora
	
	SELECT pky_usuario 
		INTO vIDUsusario
	FROM acl_usuario
	WHERE num_empleado = pEmpleado and pky_usuario='1';
	
	INSERT INTO acl_entrada_bitacora 
			(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
				fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
		VALUES(entrada_bitacora_seq.nextval, pPreDictamen, current, vFolioCsuac, vAccionPredictamen, vIDAclaracion, vAreaAcl, 
			vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
	
	--Se verifica si el Folio cuenta con Abono Temporal
	SELECT pky_resolucion
		INTO vAccionAbono
	FROM acl_resolucion 
	WHERE nombre = 'autorizarAbono';
	
	--SELECT 1 
	--	INTO vAbonoTemporal 
	--FROM acl_entrada_bitacora 
	--WHERE fky_aclaracion = vIDAclaracion 
	--	and fky_accion = vAccionAbono;
	
		SELECT 1 
			INTO vAbonoTemporal 
		FROM acl_movimiento
		WHERE fky_aclaracion = vIDAclaracion 
			and exitoso = 1 and duplicado = 0 and fky_padre is null;
	
		IF pafectacion = '1' THEN
			IF vAbonoTemporal = 1 THEN--Cuenta con Abono Temporal
				IF pProcede = 1 THEN--Procedente con Abono Temporal
					LET vAfectacion = 'Si';
					LET vIndicadorAfectacion = 1;
					
					SELECT current 
						INTO vFechaDictamen 
					FROM systables WHERE tabid = 1;
				ELIF pProcede = 0 THEN--No Procedente con Abono Temporal
					LET vDictamen = 'NP';		END IF;
			ELSE--No cuenta con Abono Temporal. Se realizaron las Afectaciones
					
				
					IF pProcede = 1 THEN--Procedente sin Abono Temporal
						LET vDictamen = 'PR';		ELIF pProcede = 0 THEN--No Procedente con Abono Temporal
						--Se corrobora si el Evento debe cobrar comision
						SELECT te.costo 
							INTO vCostoComision
						FROM acl_aclaracion acl
							INNER JOIN acl_tipo_evento te ON acl.fky_tipo_evento = te.pky_tipo_evento
						WHERE pky_aclaracion = vIDAclaracion;
						
						IF vCostoComision > 0 then--Requiere Cobro de comision
							LET vDictamen = 'CM';			ELSE --No requiere el cobro de comision
							LET vAfectacion = 'Si';
							LET vIndicadorAfectacion = 1;
							SELECT current 
								INTO vFechaDictamen 
							FROM systables WHERE tabid = 1;
						END IF;
						
					END IF;
					
			END IF;
		END IF;
	
		--Se obtienen las variables para realizar el envio de notificaciones
		--Se obtiene el nombre del Cliente
		SELECT nombre1, nombre2, apell_paterno, apell_materno 
			INTO vNombre1, vNombre2, vApellPaterno, vApellMaterno 
		FROM bdinteg:si_cliente 
		WHERE numcte = vCliente;
		
		IF pProcede = 1 THEN
			LET vTipoDictamen = 'Procedente';
		ELIF pProcede = 1 THEN
			LET vTipoDictamen = 'No Procedente';
		END IF;
		
		LET vNombreCliente = TRIM(NVL(vNombre1,'')) || ' ' || TRIM(NVL(vNombre2,'')) || ' ' || TRIM(NVL(vApellPaterno,'')) || ' ' || TRIM(NVL(vApellMaterno,''));
		
		LET v_nombre = TRIM(NVL(vNombre1,'')) || ' ' || TRIM(NVL(vNombre2,''));
		
		LET v_apellidos = TRIM(NVL(vApellPaterno,'')) || ' ' || TRIM(NVL(vApellMaterno,''));
		
		--Se obtiene el Correo Electronico del cliente
		CALL bdinteg:sp_consulta_correos ('001', vCliente,'1','0')
			RETURNING  vcodretDatosCte, vCorreoElec, vtipocorreo, vstatuscorreo;
		
		--Se obtiene el Telefono Celular del cliente
		CALL bdinteg:sp_consulta_telefonos ('001', vCliente,'2','0')
			RETURNING  vcodretDatosCte, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
				
	
	--Se identifica el Tipo Producto 1:Credito; 2:Debito
	--Se obtiene el numero de cuenta
	SELECT tpro.tipo_producto, trim(pro.numero_cuenta), tpro.producto
		INTO vTipoProducto, vCuenta, v_producto
	FROM acl_aclaracion acl
		INNER JOIN acl_producto pro ON acl.fky_producto = pro.pky_producto
		INNER JOIN acl_tipo_producto tpro ON pro.fky_tipo_producto = tpro.pky_tipo_producto
	WHERE pky_aclaracion = vIDAclaracion;
	
	IF vDictamen IS NOT NULL THEN
		IF vTipoProducto = '1' THEN--Se realizan las afectaciones dependiendo el producto
			CALL bdicred:sp_aplicaaclaracredito('001', vFolioCsuac, vDictamen, 1, pEmpleado)
			RETURNING vCodRetAfectacion;
		ELIF vTipoProducto = '2' THEN
			CALL bdicheq:sp_aplicaaclaradebito('001', vFolioCsuac, vDictamen, 1, pEmpleado)
			RETURNING vCodRetAfectacion;
		END IF;
		
		--Se guardan las variables de las afectaciones realizadas
		SELECT current 
			INTO vFechaDictamen 
		FROM systables WHERE tabid = 1;
		
		IF vCodRetAfectacion = '000' THEN 
			LET vAfectacion = 'Si';
			LET vIndicadorAfectacion = 1;
		ELSE
			LET cCodRet = vCodRetAfectacion;
			LET vResultado = 'AfectaciÃÂÃÂ³n No Realizada';
		END IF 
	END IF;
		
		IF pafectacion = '1' THEN
			IF vIndicadorAfectacion = 1 THEN
				
				SELECT pky_resolucion, descripcion 
					INTO vAccionAfectacion, vDescAfectacion
				FROM acl_resolucion 
				WHERE nombre = cAccionAfectacion;
				
				SELECT pky_estatus_corporativo
					INTO vDictamenEstatusCorp
				FROM acl_estatus_corporativo 
				WHERE nombre = 'DICTAMEN_ACEPTADA' AND activo = 1;
				
				SELECT pky_estatus_aclaracion
					INTO vDictamenEstatusAcl
				FROM acl_estatus_aclaracion 
				WHERE nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO';
				
				SELECT current 
					INTO vFechaDictamen 
				FROM systables WHERE tabid = 1;
				
				LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);
				
				
				--Se actualiza el registro en la tabla de control indicando que se realizo la afectacion
				UPDATE acl_cierre_masivo 
					SET afectacion = vAfectacion
				WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
				
				--Se realiza el Cierre de la Aclaracion
				UPDATE acl_aclaracion SET 
					fecha_dictamen = vFechaDictamen,
					fky_estatus_aclaracion = vDictamenEstatusAcl,
					fky_estatus_corp_general = vDictamenEstatusCorp,
					dias_conclusion = vDiasConclusion
				WHERE folio_csuac = vFolioCsuac;
				
				SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general
					INTO vEstatusAcl, vEstatusAna, vEstatusCorp
				FROM acl_aclaracion
				WHERE folio_csuac = vFolioCsuac;
				
				--Se registra la Afectacion realizada en la bitacora
								
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescAfectacion, current, vFolioCsuac, vAccionAfectacion, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				--Se registra en la bitacora la aceptacion del Predictamen
				SELECT pky_resolucion, descripcion 
					INTO vAccionDictamen, vDescDictamen
				FROM acl_resolucion 
				WHERE nombre = 'autorizarPredictamen';
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescDictamen, current, vFolioCsuac, vAccionDictamen, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
					
				--Se registra en la bitacora que el cierre se realizo a traves del Cierre Masivo
				SELECT pky_resolucion, descripcion 
					INTO vAccionDictamen, vDescDictamen
				FROM acl_resolucion 
				WHERE nombre = 'cierreMasivo';
				
				LET vDescDictamen = TRIM(vDescDictamen) || ' ' || pNumProceso;
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescDictamen, current, vFolioCsuac, vAccionDictamen, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				
				--Notificacion Via SMS
				--ES NECESARIO VALIDAR LA NOTIFICACION QUE SE ENVIA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
				IF vTelefono IS NOT NULL OR vTelefono <> '' THEN
				
					CALL bdimnsj:sp_registra_evento('2',cContratoSMS,cPlantilla,vCliente,'','','2',vFechaCapturaAcl,vFolioCsuac,vTipoDictamen,
						'','','','','','','','',vTelefono,0,0,0,0,0,today,'')
						RETURNING vCodretNotif;
					
				END IF;
				
				--Se registra la notificacion en la bitacora del Sistema.
				IF vCodretNotif = '00000' THEN
					LET vDescSMS = 'El mensaje de texto de notificaciÃÂÃÂ³n fuÃÂÃÂ© enviado al Cliente con ÃÂÃÂ©xito.';
					SELECT pky_resolucion 
						INTO vAccionSMS
					FROM acl_resolucion 
					WHERE nombre = 'notificacionSMSExitoso';
				ELSE
					LET vDescSMS = 'El mensaje de texto de notificaciÃÂÃÂ³n no pudo ser enviado al Cliente.';
					SELECT pky_resolucion 
						INTO vAccionSMS
					FROM acl_resolucion 
					WHERE nombre = 'notificacionSMSFallido';
				END IF;
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(ENTRADA_BITACORA_SEQ.nextval, vDescSMS, current, vFolioCsuac, vAccionSMS, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				----Notificacion Via Correo
				--ES NECESARIO VALIDAR LA NOTIFICACION QUE SE ENVIA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
				IF vCorreoElec IS NOT NULL OR vCorreoElec <> '' THEN
					--Se Obtienen variables unicas cuando se realiza en envio via correo
					LET vPreDictamen1 = SUBSTR(pPreDictamen,1,100);
					LET vPreDictamen2 = SUBSTR(pPreDictamen,101,200);
					LET vPreDictamen3 = SUBSTR(pPreDictamen,201,250);
					LET vHoraDictamen = TO_CHAR(extend(CURRENT, HOUR TO MINUTE),'%H:%M');
					LET vFechaNotifacion = TO_CHAR(CURRENT,'%d/%m/%Y');
					LET vCuentaEnmascarada = LPAD(RIGHT(vCuenta,4), length(vCuenta), 'X');
					
					LET vPreDictamen1 = NVL(vPreDictamen1,'');
					LET vPreDictamen2 = NVL(vPreDictamen2,'');
					LET vPreDictamen3 = NVL(vPreDictamen3,'');
					
					CALL bdimnsj:sp_registra_evento('1',cContratoCorreo,cPlantilla,vCliente,'','','2',vFechaCapturaAcl,vFolioCsuac,vTipoDictamen,
						vCuentaEnmascarada,vNombreCliente,vPreDictamen1,vFechaNotifacion,vPreDictamen3,vHoraDictamen,vPreDictamen2,vCorreoElec,'',
						vImporteReclamado,0,0,0,0,today,'')
							RETURNING vCodretNotif;
							--vFechaCapturaAcl
				END IF;
				
				--Se registra la notificacion en la bitacora del Sistema.
				IF vCodretNotif = '00000' THEN
					LET vDescCorreo = 'El correo electrÃÂÃÂ³nico de notificaciÃÂÃÂ³n fuÃÂÃÂ© enviado al Cliente con ÃÂÃÂ©xito.';
					SELECT pky_resolucion 
						INTO vAccionCorreo
					FROM acl_resolucion 
					WHERE nombre = 'notificacionCorreoFallido';
				ELSE
					LET vDescCorreo = 'El correo electrÃÂÃÂ³nico de notificaciÃÂÃÂ³n no pudo ser enviado al Cliente.';
					SELECT pky_resolucion 
						INTO vAccionCorreo
					FROM acl_resolucion 
					WHERE nombre = 'notificacionCorreoExitoso';
				END IF;
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,
						fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
				VALUES(ENTRADA_BITACORA_SEQ.nextval, vDescCorreo, current, vFolioCsuac, vAccionCorreo, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				--Se Concluye el Folio en la tabla de control
				LET vResultado = 'Proceso Exitoso';
				
				UPDATE acl_cierre_masivo SET 
					fky_estatus_aclaracion = vEstatusAcl,
					fky_estatus_corp_analisis = vEstatusAna, 
					fky_estatus_corp_general = vEstatusCorp,
					proceso = vResultado
				WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
				
			ELIF vIndicadorAfectacion = 0 THEN
				SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general
					INTO vEstatusAcl, vEstatusAna, vEstatusCorp
				FROM acl_aclaracion
				WHERE folio_csuac = vFolioCsuac;
				
				SELECT pky_resolucion, descripcion 
					INTO vAccionAfectacion, vDescAfectacion
				FROM acl_resolucion 
				WHERE nombre = cAccionNoAfectacion;
				
				--Se registra la No-Afectacion realizada en la bitacora
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescAfectacion, current, vFolioCsuac, vAccionAfectacion, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				--Se actualiza el registro en la tabla de control
				UPDATE acl_cierre_masivo 
					SET proceso = vResultado
				WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
				
			END IF
-------------------------------------------------------------------------------	
-------------------------------------------------------------------------------		
		ElIF pafectacion = '0' THEN
				
				
				SELECT pky_estatus_corporativo
					INTO vDictamenEstatusCorp
				FROM acl_estatus_corporativo 
				WHERE nombre = 'DICTAMEN_ACEPTADA' AND activo = 1;
				
				SELECT pky_estatus_aclaracion
					INTO vDictamenEstatusAcl
				FROM acl_estatus_aclaracion 
				WHERE nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO';
				
				SELECT current 
					INTO vFechaDictamen 
				FROM systables WHERE tabid = 1;
				
				LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);
				
				
				--Se actualiza el registro en la tabla de control indicando que se realizo la afectacion
				UPDATE acl_cierre_masivo 
					SET afectacion = vAfectacion
				WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
				
				--Se realiza el Cierre de la Aclaracion
				UPDATE acl_aclaracion SET 
					fecha_dictamen = vFechaDictamen,
					fky_estatus_aclaracion = vDictamenEstatusAcl,
					fky_estatus_corp_general = vDictamenEstatusCorp,
					dias_conclusion = vDiasConclusion
				WHERE folio_csuac = vFolioCsuac;
				
				SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general
					INTO vEstatusAcl, vEstatusAna, vEstatusCorp
				FROM acl_aclaracion
				WHERE folio_csuac = vFolioCsuac;
				
				--Se registra la Afectacion realizada en la bitacora
				LET vDescAfectacion = 'Cierre de la AclaraciÃÂÃÂ³n Mediente el Cierre Masivo sin AfectaciÃÂÃÂ³n ';
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescAfectacion, current, vFolioCsuac, '26', vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				--Se registra en la bitacora la aceptaciÃÂÃÂ³n del Predictamen
				SELECT pky_resolucion, descripcion 
					INTO vAccionDictamen, vDescDictamen
				FROM acl_resolucion 
				WHERE nombre = 'autorizarPredictamen';
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescDictamen, current, vFolioCsuac, vAccionDictamen, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
					
				--Se registra en la bitacora que el cierre se realizo a traves del Cierre Masivo
				SELECT pky_resolucion, descripcion 
					INTO vAccionDictamen, vDescDictamen
				FROM acl_resolucion 
				WHERE nombre = 'cierreMasivo';
				
				LET vDescDictamen = TRIM(vDescDictamen) || ' ' || pNumProceso;
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(entrada_bitacora_seq.nextval, vDescDictamen, current, vFolioCsuac, vAccionDictamen, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				
				--Notificacion Via SMS
				--ES NECESARIO VALIDAR LA NOTIFICACION QUE SE ENVIA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
				IF vTelefono IS NOT NULL OR vTelefono <> '' THEN
					IF v_producto <> 6500 THEN
					
						CALL bdimnsj:sp_registra_evento('2',cContratoSMS,cPlantilla,vCliente,'','','2',vFechaCapturaAcl,vFolioCsuac,vTipoDictamen,
							'','','','','','','','',vTelefono,0,0,0,0,0,today,'')
								RETURNING vCodretNotif;
					ElSE
						IF pProcede = 1 THEN
						
							CALL bdimnsj:"informix".sp_registra_evento( '2', cContratoNotCoppel, cPlantillaSMSCoppelPro, vCliente,'','','1', '' ,'' ,vFolioCsuac,'','','','','','','','', '',0,0,0,0,0,CURRENT,'')
												RETURNING vCodretNotif;
						
						ELIF pProcede = 0 THEN
						
							CALL bdimnsj:"informix".sp_registra_evento( '2', cContratoNotCoppel, cPlantillaSMSCoppelNoPro, vCliente,'','','1', '' ,'' ,vFolioCsuac,'','','','','','','','', '',0,0,0,0,0,CURRENT,'')
												RETURNING vCodretNotif;
						
						END IF;
											
					END IF;
				END IF;
				
				--Se registra la notificacion en la bitacora del Sistema.
				IF vCodretNotif = '00000' THEN
					LET vDescSMS = 'El mensaje de texto de notificacion fue enviado al Cliente con exito.';
					SELECT pky_resolucion 
						INTO vAccionSMS
					FROM acl_resolucion 
					WHERE nombre = 'notificacionSMSExitoso';
				ELSE
					LET vDescSMS = 'El mensaje de texto de notificacion no pudo ser enviado al Cliente.';
					SELECT pky_resolucion 
						INTO vAccionSMS
					FROM acl_resolucion 
					WHERE nombre = 'notificacionSMSFallido';
				END IF;
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
						fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
				VALUES(ENTRADA_BITACORA_SEQ.nextval, vDescSMS, current, vFolioCsuac, vAccionSMS, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				----Notificacion Via Correo
				--ES NECESARIO VALIDAR LA NOTIFICACION QUE SE ENVIA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
				
				IF vCorreoElec IS NOT NULL OR vCorreoElec <> '' THEN
					
					IF v_producto <> 6500 THEN
					
						--Se Obtienen variables unicas cuando se realiza en envio via correo
						LET vPreDictamen1 = SUBSTR(pPreDictamen,1,100);
						LET vPreDictamen2 = SUBSTR(pPreDictamen,101,200);
						LET vPreDictamen3 = SUBSTR(pPreDictamen,201,250);
						LET vHoraDictamen = TO_CHAR(extend(CURRENT, HOUR TO MINUTE),'%H:%M');
						LET vFechaNotifacion = TO_CHAR(CURRENT,'%d/%m/%Y');
						LET vCuentaEnmascarada = LPAD(RIGHT(vCuenta,4), length(vCuenta), 'X');
						
						LET vPreDictamen1 = NVL(vPreDictamen1,'');
						LET vPreDictamen2 = NVL(vPreDictamen2,'');
						LET vPreDictamen3 = NVL(vPreDictamen3,'');
						
						CALL bdimnsj:sp_registra_evento('1',cContratoCorreo,cPlantilla,vCliente,'','','2',vFechaCapturaAcl,vFolioCsuac,vTipoDictamen,
							vCuentaEnmascarada,vNombreCliente,vPreDictamen1,vFechaNotifacion,vPreDictamen3,vHoraDictamen,vPreDictamen2,vCorreoElec,'',
							vImporteReclamado,0,0,0,0,today,'')
								RETURNING vCodretNotif;
								--vFechaCapturaAcl
					ElSE	
						
						LET vCuentaEnmascarada = RIGHT(vCuenta,4);
						LET vCuentaEnmascarada = TRIM(vCuentaEnmascarada);
						
						IF pProcede = 1 THEN
							LET v_procedio = 'ProcediÃÂÃÂ³';
							LET v_desprocedente = 'Fue Procedente';
						ELIF  pProcede = 0 THEN
							LET v_procedio = 'No ProcediÃÂÃÂ³';
							LET v_desprocedente = 'No Fue Procedente';
						END IF;
						
						CALL bdimnsj:"informix".sp_registra_evento ('1', cContratoNotCoppel, cPlantillaCorreoCoppel, vCliente,vCuentaEnmascarada,'','1',v_nombre, v_apellidos, vFolioCsuac,
																	v_procedio, pPreDictamen,'', v_desprocedente , vTipoDictamen, '',vNombreCliente,'',
																	'',vImporteReclamado,0,0,0,0,CURRENT,'') RETURNING vCodretNotif;
	
						
						
					END IF;
				END IF;
				
				
				--Se registra la notificacion en la bitacora del Sistema.
				IF vCodretNotif = '00000' THEN
					LET vDescCorreo = 'El correo electrÃÂÃÂ³nico de notificaciÃÂÃÂ³n fuÃÂÃÂ© enviado al Cliente con ÃÂÃÂ©xito.';
					SELECT pky_resolucion 
						INTO vAccionCorreo
					FROM acl_resolucion 
					WHERE nombre = 'notificacionCorreoFallido';
				ELSE
					LET vDescCorreo = 'El correo electrÃÂÃÂ³nico de notificaciÃÂÃÂ³n no pudo ser enviado al Cliente.';
					SELECT pky_resolucion 
						INTO vAccionCorreo
					FROM acl_resolucion 
					WHERE nombre = 'notificacionCorreoExitoso';
				END IF;
				
				INSERT INTO acl_entrada_bitacora 
					(pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,
						fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
				VALUES(ENTRADA_BITACORA_SEQ.nextval, vDescCorreo, current, vFolioCsuac, vAccionCorreo, vIDAclaracion, vAreaAcl, 
					vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
				
				--Se Concluye el Folio en la tabla de control
				LET vResultado = 'Proceso Exitoso';
				
				UPDATE acl_cierre_masivo SET 
					fky_estatus_aclaracion = vEstatusAcl,
					fky_estatus_corp_analisis = vEstatusAna, 
					fky_estatus_corp_general = vEstatusCorp,
					proceso = vResultado
				WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
		
		END IF;
	
	RETURN cCodRet, vFolioCsuac, vResultado;
	
END;

END PROCEDURE
DOCUMENT
'Sp 			:	sp_aplica_cierre_masivo',
'Sistema		:	Aclaraciones',
'AUTOR 			:	Rey David',
'Area			: 	Sistemas Administrativos y Perifericos',
'Coordinador	:	Norberto Corona Berruecos',
					'Gerencia de Mtto y Soporte IV',
'FECHA 			:	21/05/2020',
'FECHA MOD		:	',
'VERSION		:	1.2.0',
'BD    			:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_reporteaclaracomisionnoprocedentenoaplicada(e_fechaIni DATE, e_fechaFin DATE,e_producto INTEGER,e_tipoBusqueda INTEGER)

RETURNING   
                           VARCHAR(11) AS folio_csuac,
                           DATETIME YEAR to FRACTION(5) AS fecha_trans,
                           VARCHAR (9) AS cliente,
                           VARCHAR (20) AS cuenta,
                           VARCHAR (16) AS tarjeta,
                           VARCHAR (100) AS nombre_cliente,
                           MONEY AS total_cobro_comision,
                           MONEY AS monto_cargado_comision,
                           MONEY AS monto_no_aplicado_comision,
                           MONEY AS total_cobro_iva,
                           MONEY AS monto_cargado_iva,
                           MONEY AS monto_no_aplicado_iva,
                           MONEY AS suma_tcc,
                           MONEY AS suma_mcc,
                           MONEY AS suma_mnac,
                           MONEY AS suma_tci,
                           MONEY AS suma_mci,
                           MONEY AS suma_mnai;

    /* Variables internas */                       
    DEFINE v_folio_csuac VARCHAR(11) ;
    DEFINE v_fecha_trans DATETIME YEAR to FRACTION(5);
    DEFINE v_cliente VARCHAR (9);
    DEFINE v_cuenta VARCHAR (20) ;
    DEFINE v_tarjeta VARCHAR (16) ;
    DEFINE v_nombre_cliente  VARCHAR(100);
    DEFINE v_total_cobro_comision MONEY;
    DEFINE v_monto_cargado_comision MONEY;
    DEFINE v_monto_no_aplicado_comision MONEY;
    DEFINE v_total_cobro_iva MONEY;
    DEFINE v_monto_cargado_iva MONEY;
    DEFINE v_monto_no_aplicado_iva MONEY;
    DEFINE v_suma_tcc MONEY;
    DEFINE v_suma_mcc MONEY;
    DEFINE v_suma_mnac MONEY;
    DEFINE v_suma_tci MONEY;
    DEFINE v_suma_mci MONEY;
    DEFINE v_suma_mnai MONEY;
    

	SET ISOLATION TO DIRTY READ;

    BEGIN
                  IF e_producto = 1 THEN --BUSQUEDA DE ACLARACIONES CON CREDITO
                    
                         FOREACH
                                SELECT  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                                rec.total_comision, rec.comision_recuperada, (rec. total_comision-comision_recuperada)AS montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, (rec. total_iva-iva_recuperada)AS montoNoAplicadoIva,SUM(rec.total_comision) AS suma_tcc,
                                                SUM(rec.comision_recuperada)AS suma_mcc, SUM(rec.total_comision - rec.comision_recuperada) AS suma_mnac, 
                                                sum(rec.total_iva) AS suma_tci,SUM (rec.iva_recuperada) AS suma_mci,SUM (rec.total_iva - rec.iva_recuperada) AS suma_mnai
                                INTO   v_folio_csuac, v_fecha_trans, v_cliente, v_cuenta, v_tarjeta, v_nombre_cliente, v_total_cobro_comision, v_monto_cargado_comision,
                                            v_monto_no_aplicado_comision, v_total_cobro_iva, v_monto_cargado_iva, v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                FROM bdiaclaracion:acl_recuperacion_saldos rec
                                    INNER JOIN bdiaclaracion:acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN bdiaclaracion:acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN bdiaclaracion:acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN bdiaclaracion:acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS not NULL AND mov.cargo=1)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                               WHERE 
                                    rec.abono_irrecuperable=1 AND tp.tipo_producto=1 AND rec.total_comision<>0 
                                    AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM bdiaclaracion:acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                    AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN e_fechaIni AND e_fechaFin)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN e_fechaIni  AND e_fechaFin) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN e_fechaIni AND e_fechaFin))
                                    GROUP BY  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                nombre_cliente,rec.total_comision, rec.comision_recuperada, montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, montoNoAplicadoIva
                                
                                RETURN v_folio_csuac,v_fecha_trans,v_cliente,v_cuenta,v_tarjeta,v_nombre_cliente, v_total_cobro_comision,v_monto_cargado_comision,v_monto_no_aplicado_comision,
                                                v_total_cobro_iva,v_monto_cargado_iva,v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                 WITH resume;
                          END FOREACH;

                END IF ---BUSQUEDA DE ACLARACIONES CON CREDITO
           
                IF e_producto = 2 THEN --BUSQUEDA DE ACLARACIONES CON DEBITO
                    
                                       FOREACH
                                SELECT  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                                rec.total_comision, rec.comision_recuperada, (rec. total_comision-comision_recuperada)AS montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, (rec. total_iva-iva_recuperada)AS montoNoAplicadoIva,SUM(rec.total_comision) AS suma_tcc,
                                                SUM(rec.comision_recuperada)AS suma_mcc, SUM(rec.total_comision - rec.comision_recuperada) AS suma_mnac, 
                                                sum(rec.total_iva) AS suma_tci,SUM (rec.iva_recuperada) AS suma_mci,SUM (rec.total_iva - rec.iva_recuperada) AS suma_mnai
                                INTO   v_folio_csuac, v_fecha_trans, v_cliente, v_cuenta, v_tarjeta, v_nombre_cliente, v_total_cobro_comision, v_monto_cargado_comision,
                                            v_monto_no_aplicado_comision, v_total_cobro_iva, v_monto_cargado_iva, v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                FROM bdiaclaracion:acl_recuperacion_saldos rec
                                    INNER JOIN bdiaclaracion:acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN bdiaclaracion:acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN bdiaclaracion:acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN bdiaclaracion:acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS not NULL AND mov.cargo=1)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                               WHERE 
                                    rec.abono_irrecuperable=1 AND tp.tipo_producto=2 AND rec.total_comision<>0 
                                    AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM bdiaclaracion:acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                    AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN e_fechaIni AND e_fechaFin)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN e_fechaIni AND e_fechaFin) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN e_fechaIni AND e_fechaFin))
                                    GROUP BY  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                nombre_cliente,rec.total_comision, rec.comision_recuperada, montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, montoNoAplicadoIva
                                
                                RETURN v_folio_csuac,v_fecha_trans,v_cliente,v_cuenta,v_tarjeta,v_nombre_cliente, v_total_cobro_comision,v_monto_cargado_comision,v_monto_no_aplicado_comision,
                                                v_total_cobro_iva,v_monto_cargado_iva,v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                 WITH resume;
                          END FOREACH;

                        
                END IF ---BUSQUEDA DE ACLARACIONES CON DEBITO
 
                IF e_producto = 3 THEN --BUSQUEDA DE ACLARACIONES AMBOS
    FOREACH
                                SELECT  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                trim(sc.nombre1)|| ' ' ||trim(sc.nombre2)||' '||trim (sc.apell_paterno) ||' '||trim(sc.apell_materno) AS nombre_cliente,
                                                rec.total_comision, rec.comision_recuperada, (rec. total_comision-comision_recuperada)AS montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, (rec. total_iva-iva_recuperada)AS montoNoAplicadoIva,SUM(rec.total_comision) AS suma_tcc,
                                                SUM(rec.comision_recuperada)AS suma_mcc, SUM(rec.total_comision - rec.comision_recuperada) AS suma_mnac, 
                                                sum(rec.total_iva) AS suma_tci,SUM (rec.iva_recuperada) AS suma_mci,SUM (rec.total_iva - rec.iva_recuperada) AS suma_mnai
                                INTO   v_folio_csuac, v_fecha_trans, v_cliente, v_cuenta, v_tarjeta, v_nombre_cliente, v_total_cobro_comision, v_monto_cargado_comision,
                                            v_monto_no_aplicado_comision, v_total_cobro_iva, v_monto_cargado_iva, v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                FROM bdiaclaracion:acl_recuperacion_saldos rec
                                    INNER JOIN bdiaclaracion:acl_aclaracion acl  ON acl.folio_csuac = rec.folio_csuac
                                    INNER JOIN bdiaclaracion:acl_producto pro ON acl.fky_producto = pro.pky_producto
                                    INNER JOIN bdiaclaracion:acl_tipo_producto tp ON tp.pky_tipo_producto=pro.fky_tipo_producto
                                    INNER JOIN bdiaclaracion:acl_movimiento mov ON (mov.folio_csuac=rec.folio_csuac AND mov.fky_padre IS not NULL AND mov.cargo=1)
                                    INNER JOIN  bdinteg:si_cliente sc ON sc.numcte = acl.num_cliente
                               WHERE 
                                    rec.abono_irrecuperable=1 AND (tp.tipo_producto=1 OR tp.tipo_producto=2) AND rec.total_comision<>0 
                                    AND pky_recuperacion = (SELECT max (pky_recuperacion) FROM bdiaclaracion:acl_recuperacion_saldos WHERE folio_csuac =acl.folio_csuac)
                                    AND ((e_tipoBusqueda = 1 AND acl.fechacaptura BETWEEN e_fechaIni AND e_fechaFin)
                                    OR   (e_tipoBusqueda = 2 AND date(acl.fecha_dictamen) BETWEEN e_fechaIni  AND e_fechaFin) 
                                    OR    (e_tipoBusqueda = 3 AND date(mov.fechahora) BETWEEN e_fechaIni AND e_fechaFin))
                                    GROUP BY  acl.folio_csuac, acl.fechacaptura,pro.num_cliente,pro.numero_cuenta,pro.numero_tarjeta,
                                                nombre_cliente,rec.total_comision, rec.comision_recuperada, montoNoAplicadoComision,
                                                rec.total_iva, rec.iva_recuperada, montoNoAplicadoIva
                                
                                RETURN v_folio_csuac,v_fecha_trans,v_cliente,v_cuenta,v_tarjeta,v_nombre_cliente, v_total_cobro_comision,v_monto_cargado_comision,v_monto_no_aplicado_comision,
                                                v_total_cobro_iva,v_monto_cargado_iva,v_monto_no_aplicado_iva,v_suma_tcc,v_suma_mcc,v_suma_mnac,v_suma_tci,v_suma_mci,v_suma_mnai
                                 WITH resume;
                          END FOREACH;

                END IF -----BUSQUEDA DE ACLARACIONES AMBOS
END; --end begin

END PROCEDURE;
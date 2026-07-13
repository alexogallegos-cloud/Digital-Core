CREATE PROCEDURE "informix".sp_consulta_saldo_cuentas(pcuenta CHAR(16), vTipoProducto CHAR(1))
RETURNING CHAR(5), numeric;

    DEFINE cCodRet              CHAR(5);	--
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
	DEFINE CMensaje             CHAR(80);

    DEFINE vFolioCsuac			CHAR(16);
	DEFINE vsaldo				numeric;

	DEFINE vstatuscta           CHAR(1);
	DEFINE cCodRetConsul        CHAR(3);	--> ok

	
	--InicializaciÃ³n de Variables
	LET cCodRet      			= '00000';
	
	
	
BEGIN

	ON EXCEPTION
            SET isam_err
            IF isam_err <> 0 THEN
				LET cCodRet = isam_err;
				RETURN  cCodRet, 0; --RETURNING
			END IF;
     END EXCEPTION;
	



	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
	--SET DEBUG FILE TO "/resplogifx/traces/sp_consulta_saldo"||"_"||""||TRIM(pcuenta)||""||".out";
--	TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

	
	IF pcuenta IS NOT NULL THEN
		

	
		IF vTipoProducto = '1' THEN--Se realizan las afectaciones dependiendo el producto
			
			SELECT (sdo_cap_insoluto + sdo_retenido)
				INTO vsaldo
			FROM bdicred:sd_maesdos WHERE num_credito = pcuenta;
			
			IF vsaldo IS NULL OR vsaldo ='' THEN
				SELECT (sdo_cap_insoluto + sdo_retenido)
				INTO vsaldo
				FROM bdicred:sd_maesdoscrd  WHERE num_credito = pcuenta;			   
			   IF vsaldo IS NULL OR vsaldo ='' THEN
					LET vsaldo = 00.00;
			   end if;
			
			END IF;
			
			
		ELIF vTipoProducto = '2' THEN
		
			CALL bdicheq:cons_saldo (pcuenta) RETURNING  cCodRetConsul,vsaldo,vstatuscta;
			
			IF vsaldo IS NULL OR vsaldo ='' THEN
				SELECT (capital - sdo_retenido)
				INTO vsaldo
				FROM bdinvers:sv_maeinv WHERE cuenta = pcuenta and secuencia = (SELECT max(secuencia) FROM bdinvers:sv_maeinv WHERE cuenta = pcuenta);
			   LET cCodRet = '00000';
			   IF vsaldo IS NULL OR vsaldo ='' THEN
					LET vsaldo = 00.00;
					LET cCodRet = '00000';
			   end if;
			ELSE 
				IF cCodRetConsul = '000' THEN
					LET cCodRet = '00000';
				END IF;
			END IF;
			
		
	
		END IF;
	
	END IF;
	

	RETURN cCodRet, vsaldo;
	
END;

END PROCEDURE
DOCUMENT
'Sp 			:	sp_consulta_saldo_cuentas',
'Sistema		:	Aclaraciones',
'AUTOR 			:	Bancoppel',
'Area			: 	Sistemas Administrativos y Perifericos',
'Coordinador	:	Norberto Corona Berruecos',
					'Gerencia de Mtto y Soporte IV',
'FECHA 			:	15/06/2020',
'VERSION		:	1.0.0',
'BD    			:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_aplica_cierre_masivo(pFolio CHAR(16), pProcede CHAR(1), pResolucion INTEGER, pOpcion CHAR(1), 
													pEmpleado CHAR (8), pPreDictamen VARCHAR(250), pNumProceso INTEGER)
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
	DEFINE vCuenta				VARCHAR(12);
	DEFINE vCuentaEnmascarada	VARCHAR(12);
	DEFINE vPreDictamen1		VARCHAR(100);
	DEFINE vPreDictamen2		VARCHAR(100);
	DEFINE vPreDictamen3		VARCHAR(60);
	DEFINE vHoraDictamen		CHAR(10);
	DEFINE vFechaNotifacion		CHAR(15);
	
	--Declaración de Constantes para los envíos de notificaciones
	DEFINE cContratoCorreo 		CHAR(10);
	DEFINE cContratoSMS 		CHAR(10);
	DEFINE cPlantilla 			CHAR(12);
	--------
	DEFINE vDescripcionAccion  VARCHAR(250);
	DEFINE vAccionInicioCierre INTEGER;
	--Inicialización de Variables
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
	
	--Inicialización Constantes
	LET cContratoCorreo 		= 'ACL_EMAIL';
	LET cContratoSMS 			= 'ACL_SMS';
	LET cPlantilla 				= 'ACL_SMS';
	
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
   
   --Obtención del Folio_CSUAC dependiendo el tipo de archivo
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
		LET vResultado = 'Opción Incorrecta';
		LET cCodRet = '002';
		INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
			VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vAfectacion, vResultado, pNumProceso);
		
		RETURN cCodRet, NULL, vResultado;
	END IF;
	
	--Extracción de variables de la Información Inicial del Folio_CSUAC
	SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, pky_aclaracion, fky_area, importereclamado, fechacaptura, 
			num_cliente
		INTO vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vIDAclaracion, vAreaAcl, vImporteReclamado, vFechaCapturaAcl, 
			vCliente
	FROM acl_aclaracion
	WHERE folio_csuac = vFolioCsuac;
	
	--Se registra en bitácora que se inica el proceso de cierre masivo
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
	
	
	IF vAbonoTemporal = 1 THEN--Cuenta con Abono Temporal
		IF pProcede = 1 THEN--Procedente con Abono Temporal
			LET vAfectacion = 'Si';
			LET vIndicadorAfectacion = 1;
			
			SELECT current 
				INTO vFechaDictamen 
			FROM systables WHERE tabid = 1;
		ELIF pProcede = 0 THEN--No Procedente con Abono Temporal
			LET vDictamen = 'NP';		END IF;
	ELSE--No cuenta con Abono Temporal. Se realizarán las Afectaciones
		IF pProcede = 1 THEN--Procedente sin Abono Temporal
			LET vDictamen = 'PR';		ELIF pProcede = 0 THEN--No Procedente con Abono Temporal
			--Se corrobora si el Evento debe cobrar comisión
			SELECT te.costo 
				INTO vCostoComision
			FROM acl_aclaracion acl
				INNER JOIN acl_tipo_evento te ON acl.fky_tipo_evento = te.pky_tipo_evento
			WHERE pky_aclaracion = vIDAclaracion;
			
			IF vCostoComision > 0 then--Requiere Cobro de comisión
				LET vDictamen = 'CM';			ELSE --No requiere el cobro de comisión
				LET vAfectacion = 'Si';
				LET vIndicadorAfectacion = 1;
				SELECT current 
					INTO vFechaDictamen 
				FROM systables WHERE tabid = 1;
			END IF;
			
		END IF;
	END IF;
	
	--Se identifica el Tipo Producto 1:Credito; 2:Debito
	--Se obtiene el número de cuenta
	SELECT tpro.tipo_producto, pro.numero_cuenta
		INTO vTipoProducto, vCuenta
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
			LET vResultado = 'Afectación No Realizada';
		END IF 
	END IF;

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
		
		LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);
		
		
		--Se actualiza el registro en la tabla de control indicando que se realizó la afectación
		UPDATE acl_cierre_masivo 
			SET afectacion = vAfectacion
		WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
		
		--Se realiza el Cierre de la Aclaración
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
		
		--Se registra la Afectacion realizada en la bitácora
		INSERT INTO acl_entrada_bitacora 
			(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
				fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
		VALUES(entrada_bitacora_seq.nextval, vDescAfectacion, current, vFolioCsuac, vAccionAfectacion, vIDAclaracion, vAreaAcl, 
			vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
		
		--Se registra en la bitácora la aceptación del Predictamen
		SELECT pky_resolucion, descripcion 
			INTO vAccionDictamen, vDescDictamen
		FROM acl_resolucion 
		WHERE nombre = 'autorizarPredictamen';
		
		INSERT INTO acl_entrada_bitacora 
			(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
				fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
		VALUES(entrada_bitacora_seq.nextval, vDescDictamen, current, vFolioCsuac, vAccionDictamen, vIDAclaracion, vAreaAcl, 
			vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
			
		--Se registra en la bitácora que el cierre se realizó a través del Cierre Masivo
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
		
		--Se obtienen las variables para realizar el envío de notificaciones
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
	  
		--Se obtiene el Correo Electrónico del cliente
		CALL bdinteg:sp_consulta_correos ('001', vCliente,'1','0')
			RETURNING  vcodretDatosCte, vCorreoElec, vtipocorreo, vstatuscorreo;
		
		--Se obtiene el Teléfono Celular del cliente
		CALL bdinteg:sp_consulta_telefonos ('001', vCliente,'2','0')
			RETURNING  vcodretDatosCte, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
		
		--Notificación Vía SMS
		--ES NECESARIO VALIDAR LA NOTIFICACIÓN QUE SE ENVÍA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
		IF vTelefono IS NOT NULL OR vTelefono <> '' THEN
		
			CALL bdimnsj:sp_registra_evento('2',cContratoSMS,cPlantilla,vCliente,'','','2',vFechaCapturaAcl,vFolioCsuac,vTipoDictamen,
				'','','','','','','','',vTelefono,0,0,0,0,0,today,'')
					RETURNING vCodretNotif;
		END IF;
        
        --Se registra la notificación en la bitácora del Sistema.
        IF vCodretNotif = '00000' THEN
			LET vDescSMS = 'El mensaje de texto de notificación fué enviado al Cliente con éxito.';
			SELECT pky_resolucion 
				INTO vAccionSMS
			FROM acl_resolucion 
			WHERE nombre = 'notificacionSMSExitoso';
        ELSE
			LET vDescSMS = 'El mensaje de texto de notificación no pudo ser enviado al Cliente.';
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
        
		----Notificación Vía Correo
		--ES NECESARIO VALIDAR LA NOTIFICACIÓN QUE SE ENVÍA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
		IF vCorreoElec IS NOT NULL OR vCorreoElec <> '' THEN
			--Se Obtienen variables únicas cuando se realiza en envío vía correo
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
		
		--Se registra la notificación en la bitácora del Sistema.
		IF vCodretNotif = '00000' THEN
			LET vDescCorreo = 'El correo electrónico de notificación fué enviado al Cliente con éxito.';
			SELECT pky_resolucion 
				INTO vAccionCorreo
			FROM acl_resolucion 
			WHERE nombre = 'notificacionCorreoFallido';
		ELSE
			LET vDescCorreo = 'El correo electrónico de notificación no pudo ser enviado al Cliente.';
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
		
		--Se registra la No-Afectacion realizada en la bitácora
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
	
	RETURN cCodRet, vFolioCsuac, vResultado;
	
END;

END PROCEDURE
DOCUMENT
'Sp 			:	sp_aplica_cierre_masivo',
'Sistema		:	Aclaraciones',
'AUTOR 			:	Bancoppel',
'Area			: 	Sistemas Administrativos y Perifericos',
'Coordinador	:	Norberto Corona Berruecos',
					'Gerencia de Mtto y Soporte IV',
'FECHA 			:	21/05/2020',
'VERSION		:	1.0.0',
'BD    			:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_aclaraciones_canales(
                        pCliente        CHAR(9))
    
    RETURNING
    
        CHAR(5)             AS cod_ret,
        CHAR(18)            AS folio_aclaracion,
        INTEGER             AS id_flujo,
        CHAR(50)            AS flujo,
        DATE                AS fechacaptura,
        MONEY               AS importereclamado,
        CHAR(50)            AS estatus_canales,
        INTEGER             AS id_aclaracion,
        CHAR(11)            AS folio_csuac;
    
    
    
    --Variables--
    DEFINE sql_err                      INTEGER;
    DEFINE v_cod_ret                    CHAR(5);
    DEFINE v_cod_ret_estatus            CHAR(5);
    DEFINE v_folio_aclaracion           CHAR(18);
    DEFINE v_id_flujo                   INTEGER;
    DEFINE v_flujo                      CHAR(50);
    DEFINE v_fechacaptura               DATE;
    DEFINE v_importereclamado           MONEY;
    
    DEFINE v_estatus_canales            CHAR(50);
    DEFINE v_concatena_dictamen         SMALLINT;
    DEFINE v_id_etapa_canales           INTEGER;
    DEFINE v_desc_etapa_canales         CHAR(20);
    
    DEFINE v_id_aclaracion              INTEGER;
    DEFINE v_folio_csuac                CHAR(11);
    
    --DEFINE c_fecha_actual             DATE;
    --DEFINE c_fecha_inicial            DATE;
    
    DEFINE v_estatus_aclaracion         INTEGER;
    DEFINE v_estatus_corp_gral          INTEGER;
    DEFINE v_estatus_corp_analisis      INTEGER;
    DEFINE v_procede                    SMALLINT;
    DEFINE v_tipo_movimiento            CHAR(1);
    
    DEFINE c_estatus_pre_ingreso        CHAR(50);
    DEFINE c_id_estatus_pre_ingreso     INTEGER;
    DEFINE c_estatus_declinado          CHAR(50);
    DEFINE c_id_estatus_declinado       INTEGER;
    DEFINE c_estatus_intento            CHAR(50);
    DEFINE c_id_estatus_intento         INTEGER;
    
    LET v_cod_ret                       = "00000";
    LET v_cod_ret_estatus               = "00000";
    LET v_folio_aclaracion              = NULL;
    LET v_id_flujo                      = NULL;
    LET v_flujo                         = NULL;
    LET v_fechacaptura                  = NULL;
    LET v_importereclamado              = NULL;
    
    LET v_estatus_canales               = NULL;
    LET v_concatena_dictamen            = NULL;
    
    LET v_id_aclaracion                 = NULL;
    LET v_folio_csuac                   = NULL;
    
    LET v_estatus_aclaracion            = NULL;    
    LET v_estatus_corp_gral             = NULL;    
    LET v_estatus_corp_analisis         = NULL;
    LET v_procede                       = NULL;
    LET v_tipo_movimiento               = NULL;
    
    LET c_estatus_pre_ingreso           = 'PRE_INGRESO';
    LET c_id_estatus_pre_ingreso        = NULL;
    LET c_estatus_declinado             = 'DECLINADA';
    LET c_id_estatus_declinado          = NULL;
    LET c_estatus_intento               = 'INTENTO';
    LET c_id_estatus_intento            = NULL;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                LET v_cod_ret = sql_err;
                
                RETURN v_cod_ret, v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado, 
                    v_estatus_canales, v_id_aclaracion, v_folio_csuac ;
            END IF;
        END EXCEPTION;
        
        LET pCliente = LPAD(TRIM(pCliente), 9, '0');
        
        --Se obtiene el Estatus Declinado
        SELECT pky_estatus_corporativo 
            INTO c_id_estatus_declinado 
        FROM acl_estatus_corporativo 
        WHERE nombre = c_estatus_declinado AND fky_tipo_estatus = 2 
            AND activo = 1;
        
        --Se obtiene el Estatus Intento determinar los que estÃ¡n en Pre-Ingreso 
        SELECT pky_estatus_aclaracion 
            INTO c_id_estatus_intento 
        FROM acl_estatus_aclaracion 
        WHERE nombre = c_estatus_intento AND activo = 1;
        
        --Se obtiene el Estatus Pre-Ingreso
        SELECT pky_estatus_corporativo 
            INTO c_id_estatus_pre_ingreso 
        FROM acl_estatus_corporativo 
        WHERE nombre = c_estatus_pre_ingreso AND fky_tipo_estatus = 2 
            AND activo = 1;
        
        FOREACH
            SELECT facl.folio_aclaracion, te.fky_tipo_flujo, tf.descripcion as flujo, acl.fechacaptura, acl.importereclamado,
                    acl.pky_aclaracion, acl.folio_csuac, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general, 
                    acl.fky_estatus_corp_analisis, procede, tipo_movimiento
                INTO v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado,
                    v_id_aclaracion, v_folio_csuac, v_estatus_aclaracion, v_estatus_corp_gral, 
                    v_estatus_corp_analisis, v_procede, v_tipo_movimiento
            FROM acl_aclaracion acl
                Inner Join acl_folio_aclaracion_acl_aclaracion facl on facl.fky_aclaracion = acl.pky_aclaracion
                Inner Join acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
                Inner Join acl_tipo_flujo tf on te.fky_tipo_flujo = tf.pky_tipo_flujo
            WHERE num_cliente = pCliente 
                AND fky_estatus_aclaracion = c_id_estatus_intento
                AND acl.fky_estatus_corp_analisis = c_id_estatus_pre_ingreso
            
            LET v_importereclamado = NVL(v_importereclamado,0);
            LET v_folio_csuac = NVL(v_folio_csuac,'');
            LET v_folio_aclaracion = NVL(v_folio_aclaracion,'');
            
            CALL sp_obten_estatus_canales(v_estatus_aclaracion, v_estatus_corp_gral, v_estatus_corp_analisis)
                    RETURNING  v_cod_ret_estatus, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
            
            IF v_concatena_dictamen = 1 THEN
                IF v_procede = 1 THEN
                    LET v_estatus_canales = TRIM(v_estatus_canales) || ' Procedente';
                ELIF v_procede = 0 THEN
                    LET v_estatus_canales = TRIM(v_estatus_canales) || ' No Procedente';
                END IF;
            END IF;
            
            RETURN v_cod_ret, v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado, 
                    v_estatus_canales, v_id_aclaracion, v_folio_csuac 
                WITH RESUME;
        END FOREACH;
        
    END;
END PROCEDURE
DOCUMENT
'Sistema        :    Aclaraciones BPI',
'CreaciÃ³n       :    BanCoppel',
'Area           :    Sistemas Administrativos y Perifericos',
                     'Gerencia de Mtto y Soporte IV',
'Coordinador    :    Norberto Corona Berruecos',
'FECHA          :    Junio/2019',
'ULT FECHA MODIF:    Junio/2020',
'Requerimiento  :    RQM 06 626; RQM 06 747',
'VERSION        :    2.0.0',
'BD             :    bdiaclaracion';

CREATE PROCEDURE "informix".sp_documentos_faltantes_canales(pIdAclaracion INTEGER, pCliente CHAR(9))

    RETURNING
        CHAR(5)                         AS cod_ret,
        INTEGER                         AS id_documento,
        CHAR(4)                         AS producto_bdidigital,
        CHAR(4)                         AS codigo_doc_bdidigital,
        CHAR(100)                       AS descripcion,
        INTEGER                         AS id_digitalizado_en_acl,
        SMALLINT                        AS existe_en_bdidigital,
        SMALLINT                        AS opcional,
        CHAR(50)                        AS nombre_acl_doc,
        DATE                            AS registro_acl_doc,
        DATE                            AS registro_bdidigital;


    --Variables--
    DEFINE sql_err                      INTEGER;
    DEFINE v_cod_ret                    CHAR(5);
    DEFINE v_existe_aclaracion          SMALLINT;
    DEFINE v_cliente_aclaracion         CHAR(9);
    DEFINE v_folio_csuac                CHAR(11);
    DEFINE v_id_documento               INTEGER;
    DEFINE v_grupo_doc                  CHAR(4);
    DEFINE v_codigo_doc                 CHAR(4);
    DEFINE v_existe_archivo_digital     SMALLINT;
    DEFINE v_desc_documento             CHAR(100);
    DEFINE v_id_digitalizado            INTEGER;
    DEFINE v_opcional                   SMALLINT;
    DEFINE v_nombre_acl_doc             CHAR(50);
    DEFINE v_fecha_registro             DATETIME YEAR to FRACTION(5);
    DEFINE v_nombre_tipo_doc            CHAR(50);
    DEFINE v_registro_acl_doc           DATE;
    DEFINE v_registro_bdidigital        DATE;
    
    DEFINE c_nombre_carta_acl           CHAR(50);
    
    LET v_cod_ret                       = '00000';
    LET sql_err                         = NULL;
    LET v_existe_aclaracion             = NULL;
    LET v_cliente_aclaracion            = NULL;
    LET v_folio_csuac                   = NULL;
    LET v_id_documento                  = NULL;
    LET v_grupo_doc                     = NULL;
    LET v_codigo_doc                    = NULL;
    LET v_existe_archivo_digital        = NULL;
    LET v_desc_documento                = NULL;
    LET v_id_digitalizado               = NULL;
    LET v_opcional                      = NULL;
    LET v_nombre_acl_doc                = NULL;
    LET v_fecha_registro                = NULL;
    LET v_nombre_tipo_doc               = NULL;
    LET v_registro_acl_doc              = NULL;
    LET v_registro_bdidigital           = NULL;
    
    LET c_nombre_carta_acl              = 'CARTA_ACLARACION';
    
    --SET DEBUG FILE TO "/informix/traces/doctos_ptes.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                
                LET v_cod_ret = sql_err;
                RETURN v_cod_ret, v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
                    v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital;
                
            END IF;
        END EXCEPTION;
        
        IF ((pCliente IS NULL) OR (pCliente = '')) AND (pIdAclaracion IS NULL) THEN
            RETURN '00002', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
                    v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --La invocaciÃ³n debe tener algÃºn valor
        END IF;
        
        IF (pIdAclaracion IS NULL) THEN
            RETURN '00003', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
                    v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --Debe proporcionar el ID de la AclaraciÃ³n
        END IF;
        
        IF (pCliente IS NULL) OR (pCliente = '') THEN
            RETURN '00004', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
                    v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --Debe proporcionar el nÃºmero de cliente
        END IF;
        
        SELECT 1, num_cliente, folio_csuac
            INTO v_existe_aclaracion, v_cliente_aclaracion, v_folio_csuac
        FROM acl_aclaracion
        WHERE pky_aclaracion = pIdAclaracion;
        
        IF (v_existe_aclaracion IS NULL) THEN
            RETURN '00005', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
                    v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --No existe la AclaraciÃ³n
        END IF;
        
        LET pCliente = LPAD(TRIM(pCliente), 9, '0');
        
        IF (pCliente <> v_cliente_aclaracion) THEN
            RETURN '00006', v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital,
                    v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital; --El cliente de la aclaraciÃ³n no coincide con el solicitado
        END IF;
        
        FOREACH
            
            SELECT tdocm.fky_tipo_documento, tdoc.descripcion, doc.pky_documento, te.grupo_doc,
                    tdg.cod_docto, tdocm.opcional, doc.nombre, doc.fecharegistro, tdoc.nombre
                INTO v_id_documento, v_desc_documento, v_id_digitalizado, v_grupo_doc,
                    v_codigo_doc, v_opcional, v_nombre_acl_doc, v_fecha_registro, v_nombre_tipo_doc
            FROM acl_aclaracion acl
                INNER JOIN acl_tipo_evento te ON acl.fky_tipo_evento = te.pky_tipo_evento
                INNER JOIN acl_tipo_doc_matriz tdocm ON fky_id_regla = fky_regla_negocio
                INNER JOIN acl_tipo_documento tdoc ON tdoc.pky_tipo_documento = tdocm.fky_tipo_documento
                LEFT OUTER JOIN acl_tipo_docto_dg_tipodocto tdg ON tdg.fky_tipo_documento = tdoc.pky_tipo_documento
                    AND te.grupo_doc = tdg.grupo_doc
                LEFT OUTER JOIN acl_documento doc ON pky_aclaracion = doc.fky_aclaracion 
                    AND tdocm.fky_tipo_documento = doc.fky_tipo_documento
            WHERE pky_aclaracion = pIdAclaracion
            
            LET v_registro_acl_doc = DATE(v_fecha_registro);
            LET v_existe_archivo_digital = NULL;
            
            --Se excluye la Carta de AclaraciÃ³n
            IF (TRIM(v_nombre_tipo_doc) = TRIM(c_nombre_carta_acl)) THEN
                LET v_nombre_tipo_doc = NULL;
                CONTINUE FOREACH;
            END IF;
            
            IF v_codigo_doc IS NOT NULL THEN
                SELECT FIRST 1 1, fecha_alta
                    INTO v_existe_archivo_digital, v_registro_bdidigital
                FROM bdidigital@coppelimg_tcp:dg_expediente exp            
                WHERE exp.producto = v_grupo_doc
                    AND exp.cod_docto = v_codigo_doc
                    AND exp.cliente = pcliente
                    AND exp.cuenta = v_folio_csuac
                    AND exp.descrip2 <> 'firma_borra_da';
            END IF;
            
            LET v_existe_archivo_digital = NVL(v_existe_archivo_digital,0);
            LET v_nombre_tipo_doc = NULL;
            
            RETURN v_cod_ret, v_id_documento, v_grupo_doc, v_codigo_doc, v_desc_documento, v_id_digitalizado, v_existe_archivo_digital, 
                        v_opcional, v_nombre_acl_doc, v_registro_acl_doc, v_registro_bdidigital
                WITH RESUME;
                        
        END FOREACH;
            
    END;
END PROCEDURE
DOCUMENT
'Sistema         :    Aclaraciones BPI',
'CreaciÃ³n        :    BanCoppel',
'Area            :    Sistemas Administrativos y Perifericos',
                      'Gerencia de Mtto y Soporte IV',
'Coordinador     :    Norberto Corona Berruecos',
'FECHA           :    Junio/2020',
'Requerimiento   :    RQM 06 747',
'VERSION         :    1.0.0',
'BD              :    bdiaclaracion';

CREATE PROCEDURE "informix".sp_dg_docsrequeridos_acl(pCodGrupo CHAR(4),pCodSistema CHAR(2),pRegistros INTEGER,pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(5) AS clave,
		CHAR(50) AS descripcion,
		CHAR(2) AS digitalizado,
		INTEGER AS tipo,
		CHAR(1) AS multi_imagen;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodDocto CHAR(5);
	DEFINE iTipoDocto INTEGER;
	DEFINE cCodGrupo CHAR(5);
	DEFINE cDescDocto CHAR(50);
	DEFINE cDescGrupo CHAR(50);
	DEFINE cClave CHAR(5);
	DEFINE cDescripcion CHAR(50);
	DEFINE cDigitalizado CHAR(2);
	DEFINE cMultiImg CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodDocto = '';
	LET iTipoDocto = NULL;
	LET cCodGrupo = '';
	LET cDescDocto = '';
	LET cDescGrupo = '';
	LET cClave = '';
	LET cDescripcion = '';
	LET cDigitalizado = '';
	LET cMultiImg = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cClave,cDescripcion,cDigitalizado,iTipoDocto,cMultiImg;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dg_docsrequeridos_acl.out';
		--TRACE ON;
		
		IF pCodGrupo = '' OR pCodSistema = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003'; --CAMPO REQUERIDO
			RETURN cCodRet,cClave,cDescripcion,cDigitalizado,iTipoDocto,cMultiImg;
		END IF;
		
		DELETE FROM bdiaclaracion:"informix".dg_docsrequeridos;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT a.cod_docto,a.fky_tipo_documento
			INTO cCodDocto,iTipoDocto
			FROM bdiaclaracion:"informix".acl_tipo_docto_dg_tipodocto AS a 
			LEFT JOIN bdidigital@coppelimg_tcp:dg_definicion AS b ON a.grupo_doc = b.cod_producto
			LEFT JOIN bdidigital@coppelimg_tcp:dg_definicion_det AS c ON a.cod_docto = c.cod_docto
			WHERE a.grupo_doc = pCodGrupo AND b.cod_sistema = pCodSistema and b.cod_definicion = c.cod_definicion
			
			FOREACH
				SELECT cod_grupo,descripcion,multi_imagen 
				INTO cCodGrupo,cDescDocto,cMultiImg
				FROM bdidigital@coppelimg_tcp:dg_tipodocumento
				WHERE empresa = cEmpresa AND cod_docto = cCodDocto
				
				INSERT INTO bdiaclaracion:"informix".dg_docsrequeridos(empresa,clave,descripcion,tipo,multi_imagen) VALUES(cEmpresa,cCodDocto,cDescDocto,iTipoDocto,cMultiImg);
				
				SELECT descripcion 
				INTO cDescGrupo
				FROM bdidigital@coppelimg_tcp:dg_grupodocto 
				WHERE empresa = cEmpresa AND cod_grupo = cCodGrupo;
				
				INSERT INTO bdiaclaracion:"informix".dg_docsrequeridos(empresa,clave,descripcion,tipo,multi_imagen) VALUES(cEmpresa,cCodGrupo,cDescGrupo,'','');
			END FOREACH;
			
		END FOREACH;
		
		--SE INICIALIZAN VARIABLES
		LET iTipoDocto = NULL;
		LET cMultiImg = '';
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			clave,TRIM(UPPER(descripcion)),digitalizado,tipo,multi_imagen
			INTO cClave,cDescripcion,cDigitalizado,iTipoDocto,cMultiImg
			FROM  bdiaclaracion:"informix".dg_docsrequeridos 
			WHERE empresa = cEmpresa
			ORDER BY id_registro ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cClave,cDescripcion,cDigitalizado,iTipoDocto,cMultiImg WITH RESUME;
			
			LET iTipoDocto = NULL;
			LET cMultiImg = '';
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017'; --NO SE ENCONTRARON DATOS
			RETURN cCodRet,cClave,cDescripcion,cDigitalizado,iTipoDocto,cMultiImg;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 27/05/2020',
'MODULO: SISTEMA DE ACLARACIONES',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de consultar el detalle de los documentos requeridos.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_acl_por_folio_canales(
                        pCliente        CHAR(9),
                        pFolio          CHAR(18))
    
    
    
    RETURNING
    
        CHAR(5)             AS cod_ret,
        CHAR(18)            AS folio_aclaracion,
        INTEGER             AS id_flujo,
        CHAR(50)            AS flujo,
        DATE                AS fechacaptura,
        MONEY               AS importereclamado,
        CHAR(50)            AS estatus_canales,
        INTEGER             AS id_aclaracion,
        CHAR(11)            AS folio_csuac;
    
    
    
    --Variables--
    DEFINE sql_err                      INTEGER;
    DEFINE v_cod_ret                    CHAR(5);
    DEFINE v_cod_ret_estatus            CHAR(5);
    
    DEFINE v_es_folio_csuac             CHAR(18);
    DEFINE v_es_folio_aclaracion        CHAR(18);
    
    DEFINE v_folio_aclaracion           CHAR(18);
    DEFINE v_id_flujo                   INTEGER;
    DEFINE v_flujo                      CHAR(50);
    DEFINE v_fechacaptura               DATE;
    DEFINE v_importereclamado           MONEY;
    
    DEFINE v_estatus_canales            CHAR(50);
    DEFINE v_concatena_dictamen         SMALLINT;
    DEFINE v_id_etapa_canales           INTEGER;
    DEFINE v_desc_etapa_canales         CHAR(20);
    
    DEFINE v_id_aclaracion              INTEGER;
    DEFINE v_folio_csuac                CHAR(11);
    
    DEFINE c_fecha_actual               DATE;
    DEFINE c_fecha_inicial              DATE;
    
    DEFINE v_estatus_aclaracion         INTEGER;
    DEFINE v_estatus_corp_gral          INTEGER;
    DEFINE v_estatus_corp_analisis      INTEGER;
    DEFINE v_procede                    SMALLINT;
    DEFINE v_tipo_movimiento            CHAR(1);
    
    DEFINE c_estatus_proceso            CHAR(50);
    DEFINE c_id_estatus_proceso         INTEGER;
    DEFINE c_estatus_cerrado            CHAR(50);
    DEFINE c_id_estatus_cerrado         INTEGER;
    
    LET v_cod_ret                       = "00000";
    LET v_cod_ret_estatus               = "00000";
    
    LET v_es_folio_csuac                = NULL;
    LET v_es_folio_aclaracion           = NULL;
    
    LET v_folio_aclaracion              = NULL;
    LET v_id_flujo                      = NULL;
    LET v_flujo                         = NULL;
    LET v_fechacaptura                  = NULL;
    LET v_importereclamado              = NULL;
    
    LET v_estatus_canales               = NULL;
    LET v_concatena_dictamen            = NULL;
    
    LET v_id_aclaracion                 = NULL;
    LET v_folio_csuac                   = NULL;
    
    LET c_fecha_actual                  = NULL;
    LET c_fecha_inicial                 = NULL;
    
    LET v_estatus_aclaracion            = NULL;    
    LET v_estatus_corp_gral             = NULL;    
    LET v_estatus_corp_analisis         = NULL;
    LET v_procede                       = NULL;
    LET v_tipo_movimiento               = NULL;
    
    LET c_estatus_proceso               = 'ACLARACION_INGRESADA';
    LET c_id_estatus_proceso            = NULL;
    LET c_estatus_cerrado               = 'ACLARACION_FINALIZADA';
    LET c_id_estatus_cerrado            = NULL;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
        ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                LET v_cod_ret = sql_err;
                
                RETURN v_cod_ret, v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado, 
                    v_estatus_canales, v_id_aclaracion, v_folio_csuac ;
            END IF;
        END EXCEPTION;
        
        LET pCliente = LPAD(TRIM(pCliente), 9, '0');
        --Se obtiene la fecha actual
		SELECT fecha_hoy
            INTO c_fecha_actual
        FROM bdinteg:si_fechas;
		
		--Se obtiene la fecha inicial para realizar la bÃºsqueda de aclaraciones
		LET c_fecha_inicial = ADD_MONTHS(c_fecha_actual, -12);
		
        --Se obtiene el Estatus En-Proceso
        SELECT pky_estatus_aclaracion 
            INTO c_id_estatus_proceso
        FROM acl_estatus_aclaracion 
        WHERE nombre = c_estatus_proceso AND activo = 1;
        
        --Se obtiene el Estatus Cerrado
        SELECT pky_estatus_aclaracion 
            INTO c_id_estatus_cerrado
        FROM acl_estatus_aclaracion 
        WHERE nombre = c_estatus_cerrado AND activo = 1;
        
        ---Se Corrobora si el folio ingresado es un folio de AclaraciÃ³n o a un folio de AclaraciÃ³n del Cliente
        SELECT 1 
            INTO v_es_folio_csuac
        FROM acl_aclaracion 
        WHERE folio_csuac = pFolio AND num_cliente = pCliente;
        
        IF v_es_folio_csuac <> 1 OR v_es_folio_csuac IS NULL THEN
            SELECT 1 
                INTO v_es_folio_aclaracion
            FROM acl_folio_Aclaracion 
            WHERE folio_aclaracion = pFolio AND num_cliente = pCliente;
        END IF;
        
        IF v_es_folio_aclaracion = 1 THEN --bÃºsqueda por folio_aclaracion
            FOREACH
                SELECT facl.folio_aclaracion, te.fky_tipo_flujo, tf.descripcion as flujo, acl.fechacaptura, acl.importereclamado,
                        acl.pky_aclaracion, acl.folio_csuac, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general, 
                        acl.fky_estatus_corp_analisis, procede, tipo_movimiento
                    INTO v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado,
                        v_id_aclaracion, v_folio_csuac, v_estatus_aclaracion, v_estatus_corp_gral, 
                        v_estatus_corp_analisis, v_procede, v_tipo_movimiento
                FROM acl_aclaracion acl
                    INNER JOIN acl_folio_aclaracion_acl_aclaracion facl on facl.fky_aclaracion = acl.pky_aclaracion
                    INNER JOIN acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
                    INNER JOIN acl_tipo_flujo tf on te.fky_tipo_flujo = tf.pky_tipo_flujo
                WHERE facl.folio_aclaracion = pfolio AND num_cliente = pCliente 
                    AND fky_estatus_aclaracion BETWEEN c_id_estatus_proceso AND c_id_estatus_cerrado
                    AND acl.fechacaptura >= c_fecha_inicial
                
                LET v_importereclamado = NVL(v_importereclamado,0);
                LET v_folio_csuac = NVL(v_folio_csuac,'');
                LET v_folio_aclaracion = NVL(v_folio_aclaracion,'');
                
                CALL sp_obten_estatus_canales(v_estatus_aclaracion, v_estatus_corp_gral, v_estatus_corp_analisis)
                        RETURNING  v_cod_ret_estatus, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
                                                                                               
                IF v_concatena_dictamen = 1 THEN
                    IF v_procede = 1 THEN
                        LET v_estatus_canales = TRIM(v_estatus_canales) || ' Procedente';
                    ELIF v_procede = 0 THEN
                        LET v_estatus_canales = TRIM(v_estatus_canales) || ' No Procedente';
                    END IF;
                END IF;
                
                RETURN v_cod_ret, v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado, 
                        v_estatus_canales, v_id_aclaracion, v_folio_csuac 
                    WITH RESUME;
            END FOREACH;
        ELIF v_es_folio_csuac = 1 THEN --BÃºsqueda por folio_CSUAC
            FOREACH
                SELECT facl.folio_aclaracion, te.fky_tipo_flujo, tf.descripcion as flujo, acl.fechacaptura, acl.importereclamado,
                        acl.pky_aclaracion, acl.folio_csuac, acl.fky_estatus_aclaracion, acl.fky_estatus_corp_general, 
                        acl.fky_estatus_corp_analisis, procede, tipo_movimiento
                    INTO v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado,
                        v_id_aclaracion, v_folio_csuac, v_estatus_aclaracion, v_estatus_corp_gral, 
                        v_estatus_corp_analisis, v_procede, v_tipo_movimiento
                FROM acl_aclaracion acl
                    LEFT OUTER JOIN acl_folio_aclaracion_acl_aclaracion facl on facl.fky_aclaracion = acl.pky_aclaracion
                    INNER JOIN acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
                    INNER JOIN acl_tipo_flujo tf on te.fky_tipo_flujo = tf.pky_tipo_flujo
                WHERE acl.folio_csuac = pfolio AND num_cliente = pCliente 
                    AND fky_estatus_aclaracion BETWEEN c_id_estatus_proceso AND c_id_estatus_cerrado
                    AND acl.fechacaptura >= c_fecha_inicial
                
                LET v_importereclamado = NVL(v_importereclamado,0);
                LET v_folio_csuac = NVL(v_folio_csuac,'');
                LET v_folio_aclaracion = NVL(v_folio_aclaracion,'');
                
                CALL sp_obten_estatus_canales(v_estatus_aclaracion, v_estatus_corp_gral, v_estatus_corp_analisis)
                        RETURNING  v_cod_ret_estatus, v_estatus_canales, v_concatena_dictamen, v_id_etapa_canales, v_desc_etapa_canales;
                
                IF v_concatena_dictamen = 1 THEN
                    IF v_procede = 1 THEN
                        LET v_estatus_canales = TRIM(v_estatus_canales) || ' Procedente';
                    ELIF v_procede = 0 THEN
                        LET v_estatus_canales = TRIM(v_estatus_canales) || ' No Procedente';
                    END IF;
                END IF;
                
                RETURN v_cod_ret, v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado, 
                        v_estatus_canales, v_id_aclaracion, v_folio_csuac 
                    WITH RESUME;
                
            END FOREACH;
        ELSE --Folio Inexistente para el cliente
            LET v_cod_ret = '00001';
            RETURN v_cod_ret, v_folio_aclaracion, v_id_flujo, v_flujo, v_fechacaptura, v_importereclamado, 
                v_estatus_canales, v_id_aclaracion, v_folio_csuac;
        END IF;
    END;
END PROCEDURE
DOCUMENT
'Sistema        :    Aclaraciones BPI',
'CreaciÃ³n       :    BanCoppel',
'Area           :    Sistemas Administrativos y Perifericos',
                     'Gerencia de Mtto y Soporte IV',
'Coordinador    :    Norberto Corona Berruecos',
'FECHA          :    Junio/2019',
'FECHA MODIF    :    Abril/2021',
'Requerimiento  :    RQM 06 626; RQM 06 747; RQI 65 581',
'VERSION        :    2.0.1',
'BD             :    bdiaclaracion';

CREATE PROCEDURE "informix".sp_reporte_acl_aud() returning char(7);
/*DEFINICIÃÂN DE VARIABLES*/
--Variables de retorno
define vcodret char(7);
define vsqlerr integer;
--Variable para ejecuciÃÂ³n de comandos
define vsql char(3000);
--Variables de elementos requeridos
define v_tarjeta          varchar(16); --PlÃÂ¡stico correspondiente a la cuenta afectada
define v_fecha_de_cargo   date;        --Fecha de cargo que se reclama
define v_fecha_abono      date;        --Fecha en que aclaraciones abona
define v_referencia23     varchar(23); --Referencia 23 de cada uno de los movimientos
define v_ref_comercio     varchar(40); --Referencia del comercio donde se afecto la cuenta
define v_edo_comercio     varchar(25); --Lugar donde se ubica el comercio
define v_nacionalidad     varchar(15); --Especificar si la aclaraciÃÂ³n se refiere a un movimiento nacional o internacional
define v_origen_operacion varchar(50); --ATM, POS, SUCURSAL INTERNET
define v_tipo_evento      integer;     --Numero de evento de acuerdo a la decisiÃÂ³n de aclaraciones
define v_evento           varchar(50); --Nombre del evento de acuerdo a la decisiÃÂ³n de aclaraciones
define v_procede          smallint;    --Procede o no procede
define v_predictamen lvarchar;         --La acciÃÂ³n que toma aclaraciones, contracargo, abono permanente o quebranto, devolucion de crÃÂ©dito
define v_monto_procedente       money;       --Monto que procedio al final de la aclaracion
define v_comision_no_procedente money;       --Comision cobrada por aclaracion no procedente
define v_importe_recuperado     money;       --RecuperaciÃÂ³n que se haya hecho del abono en el caso de que no proceda y se haga un abono temporal
--Variables NUEVAS
define v_fechacaptura    date;         --fechacapturaFecha de captura de la aclaraciÃÂ³n
define v_fecha_dictamen  date;         --Fecha del dictamen por parte de aclaraciones
define v_folio_csuac     varchar(11);  --Folio asignado por aclaraciones
define v_importeoriginal money;        --Importe por el cual se ingresa la aclaracion
define v_num_empleado    varchar(8);   --Numero del empleado que captura la aclaracion
define v_nombre_empleado varchar(150); --Nombre del empleado que captura la aclaracion
define v_analista        varchar(8);   --Analista de aclaraciones que revisa la aclaraciÃÂ³n
define v_status_acl      varchar(2);   --Estatus de la aclaraciÃÂ³n (finalizada, sin dictamen digitalizado)
define v_num_suc         varchar(4);   --Numero de sucursal donde se ingresa la aclaraciÃÂ³n
define v_sucursal        varchar(100); --Nombre de la sucursal donde ingresa la aclaracion
define v_cliente         varchar(11);  --Cliente que levanta la aclaracion
define v_numero_cuenta   varchar(20);  --Numero de la cuenta afectada
--Variables diversas
define v_tipo_movimiento    varchar(50); --
define v_tipo_producto      varchar(1);
define v_fecha_inicio       date;
define v_fecha_fin          date;
define v_estatus_inicio     integer;
define v_estatus_fin        integer;
define v_folio_suc          varchar(30);
define v_transaccion        varchar(4);
define v_producto           integer;
define v_variable_null      varchar(16);
define v_variable_date_null date;
define v_importe_rec_mov    money;
define v_importe_rec_rec    money;
define icontador            integer;
--Variables Aclaraciones ingresedadas en el periodo de un mes
define vtm_folio_csuac      varchar(11);
define vtm_fechacaptura     date;
define vtm_fecha_dictamen   date;
define vtm_importeoriginal  money;
define vtm_num_empleado     varchar(8);
define vtm_nombre_empleado  varchar(150);
define vtm_analista         varchar(8);
define vtm_status_acl       varchar(50);
define vtm_num_suc          varchar(4);
define vtm_sucursal         varchar(100);
define vtm_cliente          varchar(11);
define vtm_numero_cuenta    varchar(20);
define vtm_tarjeta          varchar(16);
define vtm_fecha_de_cargo   date;
define vtm_fecha_abono      date;
define vtm_referencia23     varchar(23);
define vtm_ref_comercio     varchar(40);
define vtm_nacionalidad     varchar(15);
define vtm_origen_operacion varchar(50);
define vtm_tipo_evento      integer;
define vtm_evento           varchar(50);
define vtm_procede          smallint;
define vtm_predictamen lvarchar;
define vtm_monto_procedente       money;
define vtm_comision_no_procedente money;
define vtm_importe_recuperado     money;
define vtm_tipo_producto          varchar(1);
define vtm_tipo_movimiento        varchar(50);
define vtm_folio_suc              varchar(30);
define vtm_transaccion            varchar(4);
define vtm_producto               integer;
define v1_temp                    integer;
define v2_temp integer;
define vtm_abono_afectado integer;
define vtm_comision_recuperada integer; 
define vtm_iva_recuperada integer; 
--Inicializacon variables Aclaraciones ingresedadas en el periodo de un mes
let v1_temp=0;
let v2_temp=0;
let vtm_abono_afectado=0; 
let vtm_comision_recuperada=0;
let vtm_iva_recuperada=0; 
let vtm_folio_csuac ='';
let vtm_fechacaptura ='';
let vtm_fecha_dictamen ='';
let vtm_importeoriginal ='';
let vtm_num_empleado ='';
let vtm_nombre_empleado ='';
let vtm_analista ='';
let vtm_status_acl ='';
let vtm_num_suc ='';
let vtm_sucursal ='';
let vtm_cliente ='';
let vtm_numero_cuenta ='';
let vtm_tarjeta ='';
let vtm_fecha_de_cargo ='';
let vtm_fecha_abono ='';
let vtm_referencia23 ='';
let vtm_ref_comercio ='';
let vtm_nacionalidad ='';
let vtm_origen_operacion ='';
let vtm_tipo_evento = 0;
let vtm_evento ='';
let vtm_procede =0;
let vtm_predictamen ='';
let vtm_monto_procedente ='';
let vtm_comision_no_procedente ='';
let vtm_importe_recuperado ='';
let vtm_tipo_producto ='';
let vtm_tipo_movimiento ='';
let vtm_folio_suc ='';
let vtm_transaccion ='';
let vtm_producto =0;
--Inicializacion de variables
let vcodret = "";
let vsqlerr = 0;
let v_estatus_inicio = 3; --Intento
let v_estatus_fin = 5;    --Finalizada
let v_variable_null = NULL;
let v_variable_date_null = NULL;
let icontador=0;
--Se elimina la informacion actual de la tabla de paso
truncate TABLE "informix".acl_reporte_acl_aud;

--SET DEBUG FILE TO "/informix/1170/Rey_David/pruebas_auditoria/pro_580_sp_reporte_acl_aud.out";
--SET DEBUG FILE TO "/resplogifx/traces/IAP/pro_580_sp_reporte_acl_aud.out";
--TRACE ON;

begin
  ON
  exception
  SET vsqlerr
  IF vsqlerr<>0 THEN
  let vcodret = vsqlerr;
  return vcodret;
end
IF;
end
exception;
set isolation TO dirty READ;
------------------------------------
select prox_fecha  AS fecha_fin,
       pri_dia_mes AS fecha_inicio
INTO   v_fecha_fin,
       v_fecha_inicio
FROM   BDINTEG:"informix".si_fechas;

------------------------------------
begin work;
  ---------::::::::::::::::::::::::::Aclaraciones ingresedadas en el periodo de un mes::::::::::::::::::::-------
  FOREACH 
  SELECT     acl.folio_csuac                                                AS folio_csuac_acl,
             acl.fechacaptura                                               AS fecha_captura_acl,
             acl.fecha_dictamen                                             AS fecha_dictamen_acl,
             acl.importeoriginal                                            AS importeorifinal_acl,
             acl.num_empleado                                               AS num_empleado_acl,
             se.nombre                                                      AS nombre_se,
             au.num_empleado                                                AS num_empleado_au,
             ea.descripcion                                                 AS descripcion_ea,
             ss.sucursal                                                    AS sucursal_ss,
             ss.nombre                                                      AS nombre_ss,
             acl.num_cliente                                                AS num_cliente_acl,
             pro.numero_cuenta                                              AS numero_cuenta_pro,
             pro.numero_tarjeta                                             AS numero_tarjeta_pro,
             date(mov.fechahora)                                            AS fecha_de_cargo,
             mov.cargo                                                      AS fecha_abono,
             mov.referencia23                                               AS referencia23,
             mov.ref_comercio                                               AS ref_comercio_mov,
             decode(acl.tipo_movimiento,'V','Nacional','F','Internacional') AS nacionalidad,
             trim(oe.descripcion)                                           AS origen_operacion,
             te.pky_tipo_evento                                             AS tipo_evento_te,
             trim(te.descripcion)                                           AS evento,
             acl.procede                                                    AS procede_acl,
             replace(replace(acl.predictamen, chr(13), ''),chr(10),'')      AS accion_aclaraciones,
             acl.montoprocedente                                            AS monto_procedente,
             te.costo                                                       AS comision_no_procedente,
			 v_variable_null,
             tpro.tipo_producto                                             AS tipo_producto_tpro,
             oe.nombre                                                      AS nombre_oe,
             mov.folio_suc                                                  AS folio_suc_mov,
             tmov.transaccion                                               AS transaccion_tmov,
             tpro.producto                                                  AS producto_tpro
  INTO       vtm_folio_csuac,
             vtm_fechacaptura ,
             vtm_fecha_dictamen ,
             vtm_importeoriginal ,
             vtm_num_empleado ,
             vtm_nombre_empleado ,
             vtm_analista ,
             vtm_status_acl ,
             vtm_num_suc ,
             vtm_sucursal ,
             vtm_cliente ,
             vtm_numero_cuenta ,
             vtm_tarjeta ,
             vtm_fecha_de_cargo ,
             vtm_fecha_abono ,
             vtm_referencia23 ,
             vtm_ref_comercio ,
             vtm_nacionalidad ,
             vtm_origen_operacion ,
             vtm_tipo_evento ,
             vtm_evento ,
             vtm_procede ,
             vtm_predictamen ,
             vtm_monto_procedente ,
             vtm_comision_no_procedente ,
             vtm_importe_recuperado ,
             vtm_tipo_producto ,
             vtm_tipo_movimiento ,
             vtm_folio_suc ,
             vtm_transaccion ,
             vtm_producto
  FROM       acl_aclaracion acl
  INNER JOIN acl_producto pro
  ON         acl.fky_producto = pro.pky_producto
  INNER JOIN acl_movimiento AS mov
  ON         acl.folio_csuac = mov.folio_csuac
  AND        mov.fky_padre IS NULL
  INNER JOIN acl_tipo_movimiento tmov
  ON         tmov.pky_tipo_movimiento = mov.fky_tipo_movimiento
  AND        duplicado = 0
  INNER JOIN acl_tipo_producto tpro
  ON         pro.fky_tipo_producto = tpro.pky_tipo_producto
  INNER JOIN acl_tipo_evento te
  ON         acl.fky_tipo_evento = te.pky_tipo_evento
  INNER JOIN acl_origen_evento oe
  ON         oe.pky_origen_evento = te.fky_origen_evento
  INNER JOIN acl_estatus_aclaracion ea
  ON         ea.pky_estatus_aclaracion = acl.fky_estatus_aclaracion
  INNER JOIN acl_usuario au
  ON         au.pky_usuario = acl.fky_usuario_analista
  INNER JOIN BDINTEG:"informix".si_sucursales ss
  ON         ss.sucursal = acl.num_sucursal
  INNER JOIN BDINTEG:"informix".si_ejecut se
  ON         se.ejecutivo = acl.num_empleado
  WHERE      acl.fechacaptura BETWEEN v_fecha_inicio AND        v_fecha_fin
  AND        acl.fky_estatus_aclaracion = 2
  
  IF vtm_fecha_abono = 1 THEN
  let vtm_fecha_abono = v_variable_date_null;
  ELSE LET vtm_fecha_abono=vtm_fechacaptura;
  end IF;
  
  if vtm_referencia23 = '' THEN
  let vtm_referencia23= v_variable_date_null;
  else let vtm_referencia23=vtm_referencia23;
  end IF;

insert INTO "informix".acl_reporte_acl_aud
            (
                        folio_csuac,
                        fechacaptura,
                        fecha_dictamen,
                        importeoriginal,
                        num_empleado,
                        nombre_empleado,
                        analista,
                        status_acl,
                        num_suc,
                        des_sucursal,
                        num_cliente,
                        numero_cuenta,
                        tarjeta,
                        fecha_de_cargo,
                        fecha_abono,
                        referencia23,
                        ref_comercio,
                        nacionalidad,
                        origen_operacion,
                        tipo_evento,
                        evento,
                        procede,
                        predictamen,
                        monto_procedente,
                        comision_no_procedente,
                        importe_recuperado,
                        tipo_producto,
                        tipo_movimiento,
                        folio_suc,
                        transaccion,
                        producto
            )
            VALUES
            (
                        vtm_folio_csuac,
                        vtm_fechacaptura ,
                        vtm_fecha_dictamen ,
                        vtm_importeoriginal ,
                        vtm_num_empleado ,
                        vtm_nombre_empleado ,
                        vtm_analista ,
                        vtm_status_acl ,
                        vtm_num_suc ,
                        vtm_sucursal ,
                        vtm_cliente ,
                        vtm_numero_cuenta ,
                        vtm_tarjeta ,
                        vtm_fecha_de_cargo ,
                        vtm_fecha_abono ,
                        vtm_referencia23 ,
                        vtm_ref_comercio ,
                        vtm_nacionalidad ,
                        vtm_origen_operacion ,
                        vtm_tipo_evento ,
                        vtm_evento ,
                        vtm_procede ,
                        vtm_predictamen ,
                        vtm_monto_procedente ,
                        vtm_comision_no_procedente ,
                        vtm_importe_recuperado ,
                        vtm_tipo_producto ,
                        vtm_tipo_movimiento ,
                        vtm_folio_suc ,
                        vtm_transaccion ,
                        vtm_producto
            );

   LET iContador = iContador + 1;
   IF iContador= 1000 THEN COMMIT WORK;
   LET iContador=0;
   BEGIN WORK;
   END IF;
END foreach;
COMMIT WORK;
LET iContador=0;



--------::::::::::::::::::::::::::Aclaraciones Dictaminadas en el periodo del mes::::::::::::::::::::-------
BEGIN WORK;
FOREACH WITH HOLD
SELECT     acl.folio_csuac,
           acl.fechacaptura,
           acl.fecha_dictamen,
           acl.importeoriginal,
           acl.num_empleado,
           se.nombre,
           au.num_empleado,
           ea.descripcion,
           ss.sucursal,
           ss.nombre,
           acl.num_cliente,
           pro.numero_cuenta,
           pro.numero_tarjeta,
           date(mov.fechahora) AS fecha_de_cargo,
           mov.cargo, 
		   mov.referencia23,
           mov.ref_comercio,
           decode(acl.tipo_movimiento, 'V','Nacional', 'F','Internacional') AS nacionalidad,
           trim(oe.descripcion) origen_operacion,
           te.pky_tipo_evento,
           trim(te.descripcion) AS evento,
           acl.procede,
           replace(replace(acl.predictamen,chr(13),''),chr(10),'') AS accion_aclaraciones,
           acl.montoprocedente                                     AS monto_procedente,
           te.costo                                                AS comision_no_procedente, 
		   acl.procede,
           tpro.tipo_producto,
           oe.nombre,
           mov.folio_suc,
           tmov.transaccion,
           tpro.producto

INTO         vtm_folio_csuac,
             vtm_fechacaptura ,
             vtm_fecha_dictamen ,
             vtm_importeoriginal ,
             vtm_num_empleado ,
             vtm_nombre_empleado ,
             vtm_analista ,
             vtm_status_acl ,
             vtm_num_suc ,
             vtm_sucursal ,
             vtm_cliente ,
             vtm_numero_cuenta ,
             vtm_tarjeta ,
             vtm_fecha_de_cargo ,
             vtm_fecha_abono ,
             vtm_referencia23 ,
             vtm_ref_comercio ,
             vtm_nacionalidad ,
             vtm_origen_operacion ,
             vtm_tipo_evento ,
             vtm_evento ,
             vtm_procede ,
             vtm_predictamen ,
             vtm_monto_procedente ,
             vtm_comision_no_procedente ,
             vtm_importe_recuperado ,
             vtm_tipo_producto ,
             vtm_tipo_movimiento ,
             vtm_folio_suc ,
             vtm_transaccion ,
             vtm_producto
     
FROM       acl_aclaracion acl
INNER JOIN acl_producto pro
ON         acl.fky_producto = pro.pky_producto
INNER JOIN acl_movimiento mov
ON         acl.folio_csuac = mov.folio_csuac
AND        mov.fky_padre IS NULL
INNER JOIN acl_tipo_movimiento tmov
ON         tmov.pky_tipo_movimiento = mov.fky_tipo_movimiento
AND        duplicado = 0
INNER JOIN acl_tipo_producto tpro
ON         pro.fky_tipo_producto = tpro.pky_tipo_producto
INNER JOIN acl_tipo_evento te
ON         acl.fky_tipo_evento = te.pky_tipo_evento
INNER JOIN acl_origen_evento oe
ON         oe.pky_origen_evento = te.fky_origen_evento
INNER JOIN acl_estatus_aclaracion ea
ON         ea.pky_estatus_aclaracion = acl.fky_estatus_aclaracion
INNER JOIN acl_usuario au
ON         au.pky_usuario = acl.fky_usuario_analista
INNER JOIN BDINTEG:"informix".si_sucursales ss
ON         ss.sucursal = acl.num_sucursal
INNER JOIN BDINTEG:"informix".si_ejecut se
ON         se.ejecutivo = acl.num_empleado
WHERE      acl.fecha_dictamen BETWEEN v_fecha_inicio  AND    v_fecha_fin
AND        acl.fky_estatus_aclaracion BETWEEN v_estatus_inicio  AND   v_estatus_fin

  IF vtm_fecha_abono = 1 THEN
  let vtm_fecha_abono = v_variable_date_null;
  ELSE LET vtm_fecha_abono=vtm_fechacaptura;
  end IF;
  
  if vtm_referencia23 = '' THEN
  let vtm_referencia23= v_variable_date_null;
  else let vtm_referencia23=vtm_referencia23;
  end IF;
  
  
	IF vtm_importe_recuperado =0 THEN 
	
	select sum(mov.monto) into v1_temp
	from   acl_movimiento mov
	WHERE  mov.folio_csuac = vtm_folio_csuac
	AND    mov.cargo = 1
	AND    mov.recuperacion = 0 ;


	SELECT max (pky_recuperacion) into v2_temp 
	FROM   acl_recuperacion_saldos recm
	WHERE  recm.folio_csuac = vtm_folio_csuac;

	SELECT abono_afectado , comision_recuperada , iva_recuperada 
	INTO   vtm_abono_afectado , vtm_comision_recuperada , vtm_iva_recuperada 
	FROM   acl_recuperacion_saldos rec
	WHERE  rec.folio_csuac = vtm_folio_csuac
	AND    pky_recuperacion = v2_temp;
  
	LET vtm_importe_recuperado =nvl(v1_temp,0) + nvl(vtm_abono_afectado,0) + nvl(vtm_comision_recuperada,0) +
	nvl(vtm_iva_recuperada,0) ;
    END IF;
	
	IF (vtm_importe_recuperado = 1 OR  vtm_importe_recuperado IS NULL) THEN 
    LET vtm_importe_recuperado= 0;
    END IF;

insert INTO "informix".acl_reporte_acl_aud
            (
                        folio_csuac,
                        fechacaptura,
                        fecha_dictamen,
                        importeoriginal,
                        num_empleado,
                        nombre_empleado,
                        analista,
                        status_acl,
                        num_suc,
                        des_sucursal,
                        num_cliente,
                        numero_cuenta,
                        tarjeta,
                        fecha_de_cargo,
                        fecha_abono,
                        referencia23,
                        ref_comercio,
                        nacionalidad,
                        origen_operacion,
                        tipo_evento,
                        evento,
                        procede,
                        predictamen,
                        monto_procedente,
                        comision_no_procedente,
                        importe_recuperado,
                        tipo_producto,
                        tipo_movimiento,
                        folio_suc,
                        transaccion,
                        producto
            )
            VALUES
            (
                        vtm_folio_csuac,
                        vtm_fechacaptura ,
                        vtm_fecha_dictamen ,
                        vtm_importeoriginal ,
                        vtm_num_empleado ,
                        vtm_nombre_empleado ,
                        vtm_analista ,
                        vtm_status_acl ,
                        vtm_num_suc ,
                        vtm_sucursal ,
                        vtm_cliente ,
                        vtm_numero_cuenta ,
                        vtm_tarjeta ,
                        vtm_fecha_de_cargo ,
                        vtm_fecha_abono ,
                        vtm_referencia23 ,
                        vtm_ref_comercio ,
                        vtm_nacionalidad ,
                        vtm_origen_operacion ,
                        vtm_tipo_evento ,
                        vtm_evento ,
                        vtm_procede ,
                        vtm_predictamen ,
                        vtm_monto_procedente ,
                        vtm_comision_no_procedente ,
                        vtm_importe_recuperado ,
                        vtm_tipo_producto ,
                        vtm_tipo_movimiento ,
                        vtm_folio_suc ,
                        vtm_transaccion ,
                        vtm_producto
            );

   LET iContador = iContador + 1;
   IF iContador= 1000 THEN COMMIT WORK;
   LET iContador=0;
   BEGIN WORK;
   END IF;
END FOREACH;
COMMIT WORK;
LET iContador=0;

begin work;
-------aclaraciones ingresadas en el mes anterior que aun estan en analisis----
FOREACH with hold
SELECT     acl.folio_csuac,
           acl.fechacaptura,
           acl.fecha_dictamen,
           acl.importeoriginal,
           acl.num_empleado,
           se.nombre,
           au.num_empleado,
           ea.descripcion,
           ss.sucursal,
           ss.nombre,
           acl.num_cliente,
           pro.numero_cuenta,
           pro.numero_tarjeta,
           date(mov.fechahora) AS fecha_de_cargo, 
		   mov.cargo, 
		   mov.referencia23,
           mov.ref_comercio,
           decode(acl.tipo_movimiento, 'V','Nacional', 'F','Internacional') AS nacionalidad,
           trim(oe.descripcion)                                                origen_operacion,
           te.pky_tipo_evento,
           trim(te.descripcion) AS evento,
           acl.procede,
           replace(replace(acl.predictamen,chr(13),''),chr(10),'') AS accion_aclaraciones,
           acl.montoprocedente                                     AS monto_procedente,
           te.costo                                                AS comision_no_procedente,
           v_variable_null,
           tpro.tipo_producto,
           oe.nombre,
           mov.folio_suc,
           tmov.transaccion,
           tpro.producto

INTO         vtm_folio_csuac,
             vtm_fechacaptura ,
             vtm_fecha_dictamen ,
             vtm_importeoriginal ,
             vtm_num_empleado ,
             vtm_nombre_empleado ,
             vtm_analista ,
             vtm_status_acl ,
             vtm_num_suc ,
             vtm_sucursal ,
             vtm_cliente ,
             vtm_numero_cuenta ,
             vtm_tarjeta ,
             vtm_fecha_de_cargo ,
             vtm_fecha_abono ,
             vtm_referencia23 ,
             vtm_ref_comercio ,
             vtm_nacionalidad ,
             vtm_origen_operacion ,
             vtm_tipo_evento ,
             vtm_evento ,
             vtm_procede ,
             vtm_predictamen ,
             vtm_monto_procedente ,
             vtm_comision_no_procedente ,
             vtm_importe_recuperado ,
             vtm_tipo_producto ,
             vtm_tipo_movimiento ,
             vtm_folio_suc ,
             vtm_transaccion ,
             vtm_producto

FROM       acl_aclaracion acl
INNER JOIN acl_producto pro
ON         acl.fky_producto = pro.pky_producto
INNER JOIN acl_movimiento mov
ON         acl.folio_csuac = mov.folio_csuac
AND        mov.fky_padre IS NULL
INNER JOIN acl_tipo_movimiento tmov
ON         tmov.pky_tipo_movimiento = mov.fky_tipo_movimiento
AND        duplicado = 0
INNER JOIN acl_tipo_producto tpro
ON         pro.fky_tipo_producto = tpro.pky_tipo_producto
INNER JOIN acl_tipo_evento te
ON         acl.fky_tipo_evento = te.pky_tipo_evento
INNER JOIN acl_origen_evento oe
ON         oe.pky_origen_evento = te.fky_origen_evento
INNER JOIN acl_estatus_aclaracion ea
ON         ea.pky_estatus_aclaracion = acl.fky_estatus_aclaracion
INNER JOIN acl_usuario au
ON         au.pky_usuario = acl.fky_usuario_analista
INNER JOIN BDINTEG:"informix".si_sucursales ss
ON         ss.sucursal = acl.num_sucursal
INNER JOIN BDINTEG:"informix".si_ejecut se
ON         se.ejecutivo = acl.num_empleado
WHERE      acl.fechacaptura < v_fecha_inicio
AND        acl.fky_estatus_aclaracion = 2

  IF vtm_fecha_abono = 1 THEN
  let vtm_fecha_abono = v_variable_date_null;
  ELSE LET vtm_fecha_abono=vtm_fechacaptura;
  end IF;
  
  if vtm_referencia23 = '' THEN
  let vtm_referencia23= v_variable_date_null;
  else let vtm_referencia23=vtm_referencia23;
  end IF;

insert INTO "informix".acl_reporte_acl_aud
            (
                        folio_csuac,
                        fechacaptura,
                        fecha_dictamen,
                        importeoriginal,
                        num_empleado,
                        nombre_empleado,
                        analista,
                        status_acl,
                        num_suc,
                        des_sucursal,
                        num_cliente,
                        numero_cuenta,
                        tarjeta,
                        fecha_de_cargo,
                        fecha_abono,
                        referencia23,
                        ref_comercio,
                        nacionalidad,
                        origen_operacion,
                        tipo_evento,
                        evento,
                        procede,
                        predictamen,
                        monto_procedente,
                        comision_no_procedente,
                        importe_recuperado,
                        tipo_producto,
                        tipo_movimiento,
                        folio_suc,
                        transaccion,
                        producto
            )
            VALUES
            (
                        vtm_folio_csuac,
                        vtm_fechacaptura ,
                        vtm_fecha_dictamen ,
                        vtm_importeoriginal ,
                        vtm_num_empleado ,
                        vtm_nombre_empleado ,
                        vtm_analista ,
                        vtm_status_acl ,
                        vtm_num_suc ,
                        vtm_sucursal ,
                        vtm_cliente ,
                        vtm_numero_cuenta ,
                        vtm_tarjeta ,
                        vtm_fecha_de_cargo ,
                        vtm_fecha_abono ,
                        vtm_referencia23 ,
                        vtm_ref_comercio ,
                        vtm_nacionalidad ,
                        vtm_origen_operacion ,
                        vtm_tipo_evento ,
                        vtm_evento ,
                        vtm_procede ,
                        vtm_predictamen ,
                        vtm_monto_procedente ,
                        vtm_comision_no_procedente ,
                        vtm_importe_recuperado ,
                        vtm_tipo_producto ,
                        vtm_tipo_movimiento ,
                        vtm_folio_suc ,
                        vtm_transaccion ,
                        vtm_producto
            );

   LET iContador = iContador + 1;
   IF iContador= 1000 THEN COMMIT WORK;
   LET iContador=0;
   BEGIN WORK;
   END IF;
END FOREACH;

COMMIT WORK;
LET iContador=0;

-------------------------------------------
----Actualiza Informacion CAMPO NACIONAL
begin work;
foreach with hold		
			SELECT folio_csuac,fechacaptura,fecha_dictamen,importeoriginal,num_empleado,nombre_empleado,analista,status_acl,
					num_suc,des_sucursal,num_cliente,numero_cuenta,tarjeta,fecha_de_cargo,fecha_abono,referencia23,ref_comercio,
					nacionalidad,origen_operacion,tipo_evento,evento,procede,predictamen,monto_procedente,comision_no_procedente,
					importe_recuperado,tipo_producto,tipo_movimiento,folio_suc,transaccion,producto
			INTO 	v_folio_csuac,v_fechacaptura,v_fecha_dictamen,v_importeoriginal,v_num_empleado,v_nombre_empleado,v_analista,v_status_acl,
					v_num_suc,v_sucursal,v_cliente,v_numero_cuenta,v_tarjeta,v_fecha_de_cargo,v_fecha_abono,v_referencia23,v_ref_comercio,
					v_nacionalidad,v_origen_operacion,v_tipo_evento,v_evento,v_procede,v_predictamen,v_monto_procedente,v_comision_no_procedente,
					v_Importe_recuperado,v_tipo_producto,v_tipo_movimiento,v_folio_suc,v_transaccion,v_producto
			FROM "informix".acl_reporte_acl_aud 
			WHERE nacionalidad is null
			
			--Actualiza la informaciÃÂ³n que se obtiene de intercard:"informix".movimiento
			IF (v_tipo_movimiento in ('POS','ATMS')) THEN
				SELECT DECODE(esnacional, 'V', 'Nacional', 'F', 'Internacional', Null)
					INTO v_nacionalidad
				FROM intercard:movimiento 
				WHERE numtarjeta = v_tarjeta and secuenciaextendida = (right(v_folio_suc,(length(trim(v_folio_suc))-1))); 	
				
				IF (v_nacionalidad='' or v_nacionalidad is null) THEN 
					SELECT DECODE(esnacional, 'V', 'Nacional', 'F', 'Internacional', Null)
						INTO v_nacionalidad
					FROM intercard:movimientohistorico 
					WHERE numtarjeta = v_tarjeta and secuenciaextendida = (right(v_folio_suc,(length(trim(v_folio_suc))-1))); 
				END IF;
				
				UPDATE "informix".acl_reporte_acl_aud SET nacionalidad = v_nacionalidad WHERE folio_csuac = v_folio_csuac;
			ELSE
				UPDATE "informix".acl_reporte_acl_aud SET nacionalidad = 'Nacional' WHERE folio_csuac = v_folio_csuac;
			END IF;
end foreach;
commit work;




--SET DEBUG FILE TO "/resplogifx/traces/IAP/acl_reporte_acl_aud.out";
--TRACE ON;
--Generacion del Reporte
let vsql = ' echo "folio_csuac|fechacaptura|fecha_dictamen|importeoriginal|num_empleado|nombre_empleado|analista|status_acl|num_suc|des_sucursal|num_cliente|numero_cuenta|tarjeta|fecha_de_cargo|fecha_abono|referencia23|ref_comercio|nacionalidad|origen_operacion|tipo_evento|evento|procede|predictamen|monto_procedente|comision_no_procedente|importe_recuperado">/resplogifx/reportesaud/REPORTEMENSUALACL_'||LPAD (MONTH(v_fecha_inicio),2,"0")||year(v_fecha_fin)||'.unl';
system vsql; 
let vsql=  'echo "UNLOAD TO /resplogifx/reportesaud/ReporteAclAud.unl '||'SELECT folio_csuac,fechacaptura,fecha_dictamen,importeoriginal,num_empleado,nombre_empleado,analista,status_acl, '||
			'num_suc,des_sucursal,num_cliente,numero_cuenta,tarjeta,fecha_de_cargo,fecha_abono,referencia23,ref_comercio, '||
			'nacionalidad,origen_operacion,tipo_evento,evento,procede,predictamen,monto_procedente,comision_no_procedente,'||
			'Importe_recuperado'||' FROM acl_reporte_acl_aud;">/resplogifx/reportesaud/ReporteAclAud.sql';
system vsql;
let vsql= 'dbaccess bdiaclaracion /resplogifx/reportesaud/ReporteAclAud.sql';
system vsql;
let vsql ='rm  /resplogifx/reportesaud/ReporteAclAud.sql';
system vsql;
let vsql = "sed 's/|$//g' /resplogifx/reportesaud/ReporteAclAud.unl >>/resplogifx/reportesaud/REPORTEMENSUALACL_"||LPAD (MONTH(v_fecha_inicio),2,"0")||year(v_fecha_fin)||'.unl';
system vsql;
let vsql ='rm  /resplogifx/reportesaud/ReporteAclAud.unl';
system vsql; 
let vcodret = '00000';					
return vcodret;
end;
end procedure
DOCUMENT
'Sp para generaciÃÂ³n de Reporte Mensual Aclaraciones',
'Es llamado desde desde la opcion 580 del menu de produccion',
'Aclaraciones',
'AUTOR : Rey David Zavala Garcia',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte IV',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 25/Enero/2018',
'FECHA : 25/Marzo/2021',
'VERSION: 1.0.0',
'VERSION: 1.0.1',
'BD    :  bdiaclaracion',
'Se creo para implementar RQM 12 039';

CREATE PROCEDURE "informix".sp_controlador_r27() Returning char(7);

/*DEFINICIÃÂN DE VARIABLES*/
--Variables de retorno
DEFINE vcodret				          char(7);	
DEFINE vsqlerr				          integer;
DEFINE pFechaCap_Ini                  varchar(20);
DEFINE pFechaCap_Fin                  varchar(20);
DEFINE resultado_FECHA_INCIO          VARCHAR(20);
DEFINE VALOR_RETORNO                  VARCHAR(20);
let vcodret = "";
let vsqlerr = 0;
let VALOR_RETORNO= "";
--SET DEBUG FILE TO "/resplogifx/traces/IAP/controladaor27";
--TRACE ON;
 
begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if;
		end exception;
		
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

let resultado_FECHA_INCIO = month(today);
if resultado_FECHA_INCIO = '1' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+89),(today),(today+89) , 0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;


if resultado_FECHA_INCIO = '4' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+90),(today),(today+90),0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
-----Si no retorna codigo exitoso
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;
-----------------------

if resultado_FECHA_INCIO = '7' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+91),(today),(today+91) , 0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;

------------------------------
if resultado_FECHA_INCIO = '10' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+91),(today),(today+91) , 0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;
-----------------------


-----------------

----Valida que el codigo de retorno sea exitoso para Control-M
if VALOR_RETORNO = '00000' THEN 
let vcodret = '00000';
ELSE let vcodret= '00001';
END IF;

return vcodret;
end;
end procedure
;
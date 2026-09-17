CREATE PROCEDURE "informix".sp_aplica_validacion_msi(pFolio_csuac CHAR(16), ptipo_msi CHAR(1))
--RETURNING CoRet CHAR(5), FolioCsuac CHAR(11), DetalleDic CHAR(70), Dictamen VARCHAR(250);
RETURNING CHAR(5) AS CoRet,CHAR(11) AS FolioCsuac, CHAR(70) AS DetalleDic, VARCHAR(250) AS Dictamen;
    DEFINE cCodRet              CHAR(6);	
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
	DEFINE vCuentaEnmascarada	VARCHAR(20);  -- PEHY
	DEFINE vPreDictamen1		VARCHAR(100);
	DEFINE vPreDictamen2		VARCHAR(100);
	DEFINE vPreDictamen3		VARCHAR(60);
	DEFINE vHoraDictamen		CHAR(10);
	DEFINE vFechaNotifacion		CHAR(15);
	
	--DeclaraciÃÂÃÂ³n de Constantes para los envÃÂÃÂ­os de notificaciones
	DEFINE cContratoCorreo 		CHAR(10);
	DEFINE cContratoSMS 		CHAR(10);
	DEFINE cPlantilla 			CHAR(12);
	--------
	DEFINE vDescripcionAccion  VARCHAR(250);
	DEFINE vAccionInicioCierre INTEGER;
	
	
	--Nuevas variables
	DEFINE vtarjeta				CHAR(20);
	--DEFINE 						CHAR(20)
	DEFINE v_plazo				CHAR(2);
	DEFINE v_fecha				DATE;
	DEFINE v_num_sol_prestamo	CHAR(20);
	DEFINE v_status				CHAR(2);
	DEFINE v_credito_can		CHAR(20);
	DEFINE v_dictamen			VARCHAR(250);
	DEFINE v_tipo_resolucion	CHAR(2);
	DEFINE v_procede			CHAR(1);
	DEFINE v_folio_suc			CHAR(20);
	DEFINE v_token_Q6			CHAR(10);
	DEFINE v_meses_sin_inte		CHAR(2);
	DEFINE v_num_meses_sin_inte CHAR(2);
	DEFINE v_detalle			VARCHAR(50);
	DEFINE pProcede				CHAR(2);
	DEFINE v_validacion_can_msi CHAR(1);
	DEFINE v_compra_meses		CHAR(1);

	DEFINE v_producto			INTEGER;  -- PEHY
	
	--InicializaciÃÂÃÂ³n de Variables

	LET v_producto				= 0;  -- PEHY

	LET cCodRet      			= '00000';
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
	
	--InicializaciÃÂÃÂ³n Constantes
	LET cContratoCorreo 		= 'ACL_EMAIL';
	LET cContratoSMS 			= 'ACL_SMS';
	LET cPlantilla 				= 'ACL_SMS';
	
	
	LET vtarjeta			 = NULL;
	--LETNE 					 = NULL;
	LET v_plazo				 = NULL;
	LET v_fecha				 = NULL;
	LET v_num_sol_prestamo	 = NULL;
	LET v_status			 = NULL;
	LET v_credito_can		 = NULL;
	LET v_dictamen			 = NULL;
	LET v_tipo_resolucion	 = NULL;
	LET v_procede			 = NULL;
	LET v_folio_suc			 = NULL;
	LET v_token_Q6			 = NULL;
	LET v_meses_sin_inte	 = NULL;
	LET v_num_meses_sin_inte = NULL;
	LET v_detalle			 = '';
	LET vfechadictamen		 = CURRENT;
	
	
	
	
BEGIN

	ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET cCodRet = sql_err;
		--ROLLBACK WORK;
		IF vResultado IS NULL THEN
			LET vResultado = 'Proceso Fallido';
		ELSE
			LET vResultado = TRIM(vResultado) || '-' || 'Proceso Fallido';
		END IF;
		
		
	/*	IF ((SELECT 1 FROM acl_cierre_masivo WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual) = 1) THEN
			UPDATE acl_cierre_masivo SET 
				proceso = vResultado
			WHERE folio_csuac = vFolioCsuac AND fecha = vFechaActual;
		ELSE
			INSERT INTO acl_cierre_masivo (fecha, folio, tipo_archivo, folio_csuac, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, afectacion, proceso, num_proceso) 
				VALUES(vFechaActual, pFolio, pOpcion, vFolioCsuac, vEstatusAcl, vEstatusAna, vEstatusCorp, vAfectacion, vResultado, pNumProceso);
		END IF*/
			
		RETURN cCodRet, vFolioCsuac, vResultado,'';
	END EXCEPTION;
	ON EXCEPTION IN (-535)
			  
			  COMMIT WORK;
				
	END EXCEPTION WITH RESUME;

	SELECT current 
		INTO vFechaActual 
	FROM systables WHERE tabid = 1;

	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
	--SET DEBUG FILE TO "/resplogifx/Rey_David/sp_aplica_meses"||"_"||""||TRIM(pFolio_csuac)||""||".out";
	--TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   
	/*SELECT pky_resolucion, descripcion
		INTO vAccionInicioCierre, vDescripcionAccion
	FROM acl_resolucion
	WHERE nombre = 'iniciocierreMasivo';*/
	
	SELECT pky_usuario 
		INTO vIDUsusario
	FROM acl_usuario
	WHERE  pky_usuario='1';
   
   -----
   
   	SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, pky_aclaracion, fky_area, importereclamado, fechacaptura, 
			num_cliente
		INTO vEstatusAclInicial, vEstatusAnaInicial, vEstatusCorpInicial, vIDAclaracion, vAreaAcl, vImporteReclamado, vFechaCapturaAcl, 
			vCliente
	FROM acl_aclaracion
	WHERE folio_csuac = pFolio_csuac;
   
   
   LET vFolioCsuac = pFolio_csuac;
   
   	SELECT tpro.tipo_producto, tpro.producto , trim(pro.numero_cuenta), pro.numero_tarjeta, te.validacion_can_msi , te.compra_meses 
		INTO vTipoProducto, v_producto , vCuenta, vtarjeta, v_validacion_can_msi, v_compra_meses 
	FROM acl_aclaracion acl
		INNER JOIN acl_producto pro ON acl.fky_producto = pro.pky_producto
		INNER JOIN acl_tipo_producto tpro ON pro.fky_tipo_producto = tpro.pky_tipo_producto
		INNER JOIN acl_tipo_evento te on acl.fky_tipo_evento = te.pky_tipo_evento
	WHERE pky_aclaracion = vIDAclaracion;
   
   SELECT folio_suc INTO v_folio_suc FROM acl_movimiento WHERE fky_aclaracion =  vIDAclaracion and duplicado = '0' and fky_padre is null;
   
   SELECT plazo, fecha, num_sol_prestamo, status 
	INTO v_plazo, v_fecha, v_num_sol_prestamo, v_status 
   FROM bdicred:sd_promocion_credito WHERE num_cte = vCliente and num_credito = vCuenta and num_tarjeta = vtarjeta and num_pro_prestamo = '8900' AND folio_suc = v_folio_suc;
   
   --PEHY
    IF v_producto != '4900' THEN


		IF   vTipoProducto = '1' THEN
		
			IF v_num_sol_prestamo IS NOT NULL THEN
					
					IF v_validacion_can_msi = '1' then
					
						SELECT num_credito into v_credito_can
						FROM  bdicred:sd_msi_cancela_credito_msi where num_credito = v_num_sol_prestamo and canal = '1';
						
						IF v_credito_can IS NOT NULL THEN
						
							LET v_dictamen = 'Solicitud procede, la cancelacion de compras a meses se encuentra aplicada';
							LET v_tipo_resolucion = '6';
							LET v_procede = '1';
							
						
						ELSE
							
							LET v_dictamen = 'Solicitud no procede, porque el cliente no autorizo cancelacion mediante huella dactilar.';
							LET v_tipo_resolucion = '5';
							LET v_procede = '0';
			
						END IF;
						
					
					
					ELIF v_compra_meses = '1' THEN
						
						LET vImporteReclamado = 0;
						LET v_procede = '0';
						LET v_tipo_resolucion = '5';
						
						IF v_status = 2 THEN
						
						
							--SELECT folio_suc INTO v_folio_suc FROM acl_movimiento WHERE fky_aclaracion =  vIDAclaracion and duplicado = '0' and fky_padres is null;
							
							LET v_folio_suc = substr(v_folio_suc,2);
							
							SELECT  SUBSTR(SUBSTRING_INDEX(tokens63in,'! Q600006 ',-1),1,6) INTO v_token_Q6
							FROM intercard:movimiento WHERE numtarjeta = vtarjeta and secuenciaextendida = v_folio_suc;
						
							LET v_meses_sin_inte = SUBSTR(v_token_Q6, 5,2);
							LET v_num_meses_sin_inte = SUBSTR(v_token_Q6, 3,2);
							
								
								IF v_token_Q6 IS NOT NULL OR v_token_Q6 <> '' THEN
									
									IF v_meses_sin_inte = '03' THEN
									
										LET v_dictamen =  'Solicitud no procede, ya que la transaccion se registro a '|| v_num_meses_sin_inte ||' meses, si desea cancelar la compara acudir a cualquier sucursal a realizar el tramite.';
									
									ELSE
									
										--LET v_meses_sin_inte = SUBSTR(v_token_Q6, 3,2);
										LET v_dictamen = 'Solicitud no procede, ya que la transaccion no es una compra a Meses sin Intereses.';
										
														
									END IF;
									
								ELSE
								
									LET v_dictamen = 'Solicitud no procede, ya que la transaccion no es una compra a Meses sin Intereses.';
								
								END IF;
						
						
						ELSE
							
							LET vImporteReclamado = 0;
							
							IF v_status = 0 THEN
							
								LET v_dictamen =  'No procede: en proceso de confirmacion para Meses Sin Intereses.';
								
							ELIF v_status = '1' THEN
								
								LET v_dictamen =  'No procede: en proceso de diferimiento de Meses Sin Intereses.';
							
							ELIF v_status IN('4','6','7','8') THEN
							
								LET v_dictamen =  'No procede: cuenta no cumplio con las condiciones para aplicar a Meses Sin Intereses.';
							
							END IF;
						
						END IF;
					
					END IF;
					
			ELSE
						
						LET vImporteReclamado = 0;
						LET v_procede = '0';
						LET v_tipo_resolucion = '5';
						
						LET v_dictamen =  'Solicitud no procede, ya que la transacciÃÂÃÂ³n no es una compra a Meses sin Intereses.';
			
			
			END IF;
				--ExtracciÃÂÃÂ³n de variables de la InformaciÃÂÃÂ³n Inicial del Folio_CSUAC
			
				IF v_dictamen IS NOT NULL THEN
				
						LET pProcede = v_procede;
					
					--Se realiza el Predictamen del Folio_CSUAC
					
					SELECT pky_estatus_corporativo, fky_accion
						INTO vPredictamenEstatusCorp, vAccionPredictamen
					FROM acl_estatus_corporativo 
					WHERE nombre = 'PREDICTAMINADA' AND activo = 1;
					
					LET v_dictamen = replace(replace(v_dictamen,chr(13),''),chr(10),'');
					--Se actualiza el Folio a Predictaminado
					
					UPDATE acl_aclaracion SET 
						Montoprocedente = vImporteReclamado,
						Predictamen = v_dictamen,
						Procede = pProcede,
						fky_estatus_corp_general = vPredictamenEstatusCorp,
						fky_tipo_codigo_resolucion = v_tipo_resolucion
					WHERE folio_csuac = vFolioCsuac;
					
					--Se Registra el predictamen en la tabla de control
					SELECT fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general
						INTO vEstatusAcl, vEstatusAna, vEstatusCorp
					FROM acl_aclaracion
					WHERE folio_csuac = vFolioCsuac;
					
						LET vResultado = 'Predictaminado';
					
						INSERT INTO acl_entrada_bitacora 
							(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
								fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
						VALUES(entrada_bitacora_seq.nextval, v_dictamen, current, vFolioCsuac, vAccionPredictamen, vIDAclaracion, vAreaAcl, 
							vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
					
						
						SELECT pky_estatus_corporativo
							INTO vDictamenEstatusCorp
						FROM acl_estatus_corporativo 
						WHERE nombre = 'DICTAMEN_ACEPTADA' AND activo = 1;
						
						SELECT pky_estatus_aclaracion
							INTO vDictamenEstatusAcl
						FROM acl_estatus_aclaracion 
						WHERE nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO';
						
						LET vDiasConclusion = (date(vFechaDictamen) - vFechaCapturaAcl + 1);
										
						--Se realiza el Cierre de la AclaraciÃÂÃÂ³n
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
						
						--Se registra en la bitÃÂÃÂ¡cora la aceptaciÃÂÃÂ³n del Predictamen
						SELECT pky_resolucion, descripcion 
							INTO vAccionDictamen, vDescDictamen
						FROM acl_resolucion 
						WHERE nombre = 'autorizarPredictamen';
						
						INSERT INTO acl_entrada_bitacora 
							(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, 
								fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
						VALUES(entrada_bitacora_seq.nextval, vDescDictamen, current, vFolioCsuac, vAccionDictamen, vIDAclaracion, vAreaAcl, 
							vEstatusAcl, vEstatusAna, vEstatusCorp, vIDUsusario);
							
						--Se obtiene el nombre del Cliente
						SELECT nombre1, nombre2, apell_paterno, apell_materno 
							INTO vNombre1, vNombre2, vApellPaterno, vApellMaterno 
						FROM bdinteg:si_cliente 
						WHERE numcte = vCliente;
						
						IF pProcede = 1 THEN
							LET vTipoDictamen = 'Procedente';
						ELIF pProcede = 0 THEN
							LET vTipoDictamen = 'No Procedente';
						END IF;
						
						LET vNombreCliente = TRIM(NVL(vNombre1,'')) || ' ' || TRIM(NVL(vNombre2,'')) || ' ' || TRIM(NVL(vApellPaterno,'')) || ' ' || TRIM(NVL(vApellMaterno,''));
					
						--Se obtiene el Correo ElectrÃÂÃÂ³nico del cliente
						CALL bdinteg:sp_consulta_correos ('001', vCliente,'1','0')
							RETURNING  vcodretDatosCte, vCorreoElec, vtipocorreo, vstatuscorreo;
						
						--Se obtiene el TelÃÂÃÂ©fono Celular del cliente
						CALL bdinteg:sp_consulta_telefonos ('001', vCliente,'2','0')
							RETURNING  vcodretDatosCte, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
						
						--NotificaciÃÂÃÂ³n VÃÂÃÂ­a SMS
						--ES NECESARIO VALIDAR LA NOTIFICACIÃÂÃÂN QUE SE ENVÃÂÃÂA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
						IF vTelefono IS NOT NULL OR vTelefono <> '' THEN
						
							CALL bdimnsj:sp_registra_evento('2',cContratoSMS,cPlantilla,vCliente,'','','2',vFechaCapturaAcl,vFolioCsuac,vTipoDictamen,
								'','','','','','','','',vTelefono,0,0,0,0,0,today,'')
									RETURNING vCodretNotif;
						END IF;
						
						--Se registra la notificaciÃÂÃÂ³n en la bitÃÂÃÂ¡cora del Sistema.
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
						
						----NotificaciÃÂÃÂ³n VÃÂÃÂ­a Correo
						--ES NECESARIO VALIDAR LA NOTIFICACIÃÂÃÂN QUE SE ENVÃÂÃÂA, PARA PODER DETERMINAR LAS VARIABLES A CONSIDERAR
						IF vCorreoElec IS NOT NULL OR vCorreoElec <> '' THEN
							--Se Obtienen variables ÃÂÃÂºnicas cuando se realiza en envÃÂÃÂ­o vÃÂÃÂ­a correo
							LET vPreDictamen1 = SUBSTR(v_dictamen,1,100);
							LET vPreDictamen2 = SUBSTR(v_dictamen,101,200);
							LET vPreDictamen3 = SUBSTR(v_dictamen,201,250);
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
						
						--Se registra la notificaciÃÂÃÂ³n en la bitÃÂÃÂ¡cora del Sistema.
						IF vCodretNotif = '00000' THEN
							LET vDescCorreo = 'El correo electronico de notificacion fue enviado al Cliente con exito.';
							SELECT pky_resolucion 
								INTO vAccionCorreo
							FROM acl_resolucion 
							WHERE nombre = 'notificacionCorreoFallido';
						ELSE
							LET vDescCorreo = 'El correo electronico de notificacion no pudo ser enviado al Cliente.';
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
						
						IF pProcede = 0 THEN
							LET v_detalle = 'Folio Dictaminada no Procedente';
						ELIF pProcede = 1 THEN
							LET v_detalle = 'Folio Dictaminada Procedente';
						END IF;
							
						LET vResultado = 'Proceso Exitoso: '||v_detalle||'.';
				END IF;
			--END IF;
		ELSE
		
			RETURN cCodRet, vFolioCsuac, 'Folio no pertenece a credito', v_dictamen;
	
		END IF;
	ELSE 

		RETURN cCodRet, vFolioCsuac, ' ', v_dictamen;

	END IF;
	
	RETURN cCodRet, vFolioCsuac, vResultado, v_dictamen;
	
END;

END PROCEDURE
DOCUMENT
'Sp 			:	sp_aplica_validacion_msi',
'Sistema		:	Aclaraciones',
'AUTOR 			:	Rey David Zavala Garcia',
'Area			: 	Sistemas Administrativos y Perifericos',
'Coordinador	:	Norberto Corona Berruecos',
					'Gerencia de Mtto y Soporte IV',
'FECHA 			:	',
'VERSION		:	1.0.0',
'BD    			:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_cred_cuenta(p_sNumeroCuenta CHAR(20), p_skip INT, p_sNumeroEmpresa CHAR(3))
	RETURNING CHAR(6) AS numeroProducto, CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;
	
	-- Definicion de variables 
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto         CHAR(60);
	DEFINE resultado_numeroCuenta           CHAR(30);
	DEFINE resultado_numeroTarjeta          CHAR(30);
	DEFINE iSqlErr                          INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
    -- Inicializacion de variables
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';
	
    --SET DEBUG FILE TO "/home/e10000263/sp_busca_producto_cred_cuenta.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
            END IF;
        END EXCEPTION;
		
        FOREACH
			SELECT SKIP p_skip bdicred:sd_definicion.num_producto,nombre_prod, num_credito, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
			FROM bdicred:sd_maecred 
				LEFT JOIN bdicred:sd_definicion 
					ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa 
					AND bdicred:sd_definicion.num_producto = bdicred:sd_maecred.num_producto) 
				LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
				LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
				WHERE num_credito = p_sNumeroCuenta
				AND bdicred:sd_maecred.status_cred IN ('AA' ,'BA', 'BT','E1','E2','E3') 		--IFRS 
				ORDER BY num_credito asC
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta WITH RESUME;
        END FOREACH;
		
        -- Agregado TDC COPPEL MASTER CARD		
		FOREACH
			SELECT SKIP p_skip intercard:binproducto.codprodcta as numeroProducto, intercard:binproducto.desccodprodcta AS nombreProducto, intercard:tarjetacuenta.numcuenta AS cuentaProducto, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
            FROM intercard:tarjeta      
				LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
				LEFT JOIN intercard:binproducto ON (intercard:binproducto.codproductotarjeta = intercard:tarjeta.codproductotarjeta)
			WHERE intercard:tarjeta.codstatustarjeta IN ('ACT','BLO','BLT','CAN','DAN','EXT','FAL','INA','ROB')
			AND intercard:tarjetacuenta.numcuenta = p_sNumeroCuenta
			AND intercard:tarjeta.codproductotarjeta = '007'
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;    
		END FOREACH;
		
		-- Agregado TDC Smart Vista		
		FOREACH
		
			select num_producto, num_cuenta_clabe,num_tdc
				into resultado_numeroProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			from bdinteg:si_credito_sv
			where num_cuenta_clabe = p_sNumeroCuenta
			
			
			SELECT descripcion
			INTO  resultado_nombreProducto
			FROM "informix".acl_tipo_producto 
			WHERE producto = resultado_numeroProducto and activo = '1';
		
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, '';    
		END FOREACH;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de productos correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_prod_sv(pProducto CHAR(6))
         RETURNING 	CHAR(5) AS codRet,  
					CHAR(6) AS tipoProducto;
					--CHAR(60) AS nombreProducto, 
					--CHAR(30) AS numeroCuenta, 
					--CHAR(30) AS numeroTarjeta,
					--INTEGER AS tipoProducto;
						
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    
	DEFINE cNumeroProducto CHAR(6);
    DEFINE cNombreProducto CHAR(60);
    DEFINE cNumeroCuenta CHAR(30);      
    DEFINE cNumeroTarjeta CHAR(30);   
	DEFINE cStatusTarjeta CHAR(3);	

	DEFINE cNumeroCuentaInversion CHAR(30);	
	DEFINE cTelefonoTransfer CHAR(30); 
	DEFINE cClienteTransfer CHAR(30);	
	DEFINE iRecuperacion INTEGER;
    DEFINE cEmpresa CHAR(3);  
	DEFINE iTipoProducto INTEGER;
    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    
	LET cNumeroProducto = '';
    LET cNombreProducto = '';
	LET cNumeroCuenta='';
	LET cNumeroTarjeta='';
	
	LET cNumeroCuentaInversion='';
	LET cTelefonoTransfer='';
	LET cClienteTransfer='';
	LET iRecuperacion = 0;
	LET cEmpresa='001';
	LET iTipoProducto = 0;
	LET cStatusTarjeta = '';
   	
	 BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipoProducto;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/home/e10000263/sp_busca_producto.out';
		--TRACE ON;
		
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
		
			SELECT descripcion,  pky_tipo_producto
			INTO  cNombreProducto,iTipoProducto 
			FROM "informix".acl_tipo_producto 
			--INNER JOIN "informix".acl_tipo_producto b ON a.numero_producto = pProducto 
			WHERE producto = pProducto and activo = '1';
			
			--LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iTipoProducto;		
		
    END;
	
END PROCEDURE;